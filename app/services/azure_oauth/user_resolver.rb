module AzureOauth
  # Maps a validated set of Entra claims onto a PQ user, provisioning or
  # reactivating as needed. This is where the identity decision lives.
  #
  # Resolution order:
  #
  #   1. a row already holding this oid          -> identity settled
  #   2. a case-insensitive email match          -> link it, once, and log
  #   3. nothing                                 -> provision a PQUSER
  #
  # Email is trusted exactly once per account, at step 2. After that the
  # account is pinned to an oid and an email match onto a row holding a
  # different oid is refused — that is the one case where trust-on-first-use
  # could be abused by an address reassigned within the tenant.
  class UserResolver
    # Raised when the claims cannot be mapped onto an account this person is
    # entitled to. The callback turns it into the generic sign-in failure page;
    # the reason is logged, never rendered.
    class IdentityConflict < StandardError; end

    # Long enough to be unguessable. It exists only to satisfy :validatable —
    # nobody knows it, and with the password routes unmounted there is no
    # endpoint that would accept it.
    PASSWORD_LENGTH = 64

    def initialize(claims)
      @claims = claims
    end

    def call
      resolve
    rescue ActiveRecord::RecordNotUnique
      adopt_race_winner
    rescue ActiveRecord::RecordInvalid => e
      # The spec requires every failure to land on a PQ-owned error page, so a
      # record the tenant's data cannot satisfy must not escape as a 500.
      raise IdentityConflict, "could not persist the identity for oid #{oid}: #{e.record&.errors&.full_messages&.join(', ')}"
    end

  private

    attr_reader :claims

    def resolve
      User.transaction do
        user = find_by_oid || link_by_email || provision
        refresh!(user)
        user
      end
    end

    # Another callback committed the same oid between our lookup and our write
    # — a double-clicked handoff button produces exactly this. The winner's row
    # is the identity, so adopt it rather than turning a successful sign-in
    # into a 500. Our transaction has already rolled back, so the row we were
    # about to link carries no partial write.
    #
    # If the clash was on email rather than oid the lookup below finds nothing,
    # and the refusal is correct: we have no proven identity to return.
    def adopt_race_winner
      winner = User.find_by(azure_oid: oid)
      raise IdentityConflict, "oid #{oid} was claimed concurrently and could not be re-read" if winner.nil?

      User.transaction { refresh!(winner) }
      winner
    end

    # A plain finder on purpose. User has no default_scope, so this sees
    # soft-deleted rows, which is required: a returning removed user must be
    # reactivated in place, never duplicated. Do not reach for `active` here.
    def find_by_oid
      User.find_by(azure_oid: oid)
    end

    def link_by_email
      user = find_by_email
      return if user.nil?

      if user.azure_oid.present? && user.azure_oid != oid
        raise IdentityConflict,
              "oid #{oid} matched user #{user.id} by email, but that account is already pinned to another identity"
      end

      user.azure_oid = oid

      # The audit trail for an address reassigned in the tenant to a different
      # human: that person inherits this row's history, and this line is what
      # makes it recoverable after the fact.
      LogStuff.warn(:oauth) do
        "Linking oid #{oid} to existing user #{user.id} on first use, matched by email address"
      end

      user
    end

    def find_by_email
      return if email.blank?

      User.where("lower(email) = ?", email.downcase).first
    end

    def provision
      raise IdentityConflict, "cannot provision an account for oid #{oid}: no email claim" if email.blank?

      User.new(
        azure_oid: oid,
        email: email,
        roles: User::ROLE_PQ_USER,
        password: Devise.friendly_token(PASSWORD_LENGTH),
      )
    end

    # One write, inside the caller's transaction. Assigning and saving once
    # rather than calling SoftDeletion#activate! is deliberate: activate! uses
    # `update`, which returns false on a validation failure instead of raising,
    # so a reactivation that could not be persisted would pass silently.
    def refresh!(user)
      reactivate(user) if user.deleted?
      clear_lock(user)
      user.name = resolved_name(user)
      user.email = email if sync_email?(user)
      user.save!
    end

    # A returning removed user comes back as a basic user whatever they were
    # before, so re-enabling an account cannot silently restore admin rights.
    # Only applied to rows that are actually deleted — an active admin signing
    # in normally keeps their role.
    def reactivate(user)
      user.deleted = false
      user.roles = User::ROLE_PQ_USER

      LogStuff.warn(:oauth) do
        "Reactivating soft-deleted user #{user.id} for oid #{oid}; roles reset to #{User::ROLE_PQ_USER}"
      end
    end

    # failed_attempts counts failed PASSWORD attempts, which cannot grow once
    # the password routes are unmounted, and the unlock route is not mounted
    # either — so a lock predating cutover would strand its owner permanently.
    # Entra having just authenticated them supersedes a stale lock.
    def clear_lock(user)
      user.failed_attempts = 0
      user.locked_at = nil
      user.unlock_token = nil
    end

    # Entra wins when it sends a name; otherwise keep what is already there
    # rather than overwriting a real name with an email local part. The local
    # part is the last resort, and exists because User validates name presence.
    def resolved_name(user)
      claims.name.presence || user.name.presence || email_local_part
    end

    def email_local_part
      email.to_s.split("@").first.presence
    end

    # The oid is proof of identity; email is a display and notification field.
    # Refusing a provably legitimate user over a data collision is the worse
    # outcome, so the sync is skipped and logged for an admin to resolve.
    def sync_email?(user)
      return false if email.blank?
      return false if user.email.to_s.casecmp?(email)
      return true unless email_held_by_another?(user)

      LogStuff.warn(:oauth) do
        "Skipping email sync for user #{user.id} (oid #{oid}): that address is already held by another account"
      end

      false
    end

    def email_held_by_another?(user)
      scope = User.where("lower(email) = ?", email.downcase)
      scope = scope.where.not(id: user.id) if user.persisted?
      scope.exists?
    end

    def oid
      @oid ||= claims.oid
    end

    def email
      return @email if defined?(@email)

      @email = claims.email
    end
  end
end
