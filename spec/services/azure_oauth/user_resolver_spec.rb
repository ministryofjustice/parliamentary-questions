require "rails_helper"

RSpec.describe AzureOauth::UserResolver do
  # A verifying double, so that a change to Claims' interface fails here
  # rather than silently passing against a stale stub.
  def claims(oid: "oid-default", email: "jane.smith@justice.gov.uk", name: "Jane Smith")
    instance_double(AzureOauth::Claims, oid: oid, email: email, name: name)
  end

  def warnings_from
    messages = []
    allow(LogStuff).to receive(:warn) { |*_args, &block| messages << block.call }
    yield
    messages.join("\n")
  end

  describe "#call" do
    context "when a user already holds the oid" do
      it "returns that user" do
        user = create(:user, email: "held@justice.gov.uk", name: "Held", azure_oid: "oid-1")

        expect(described_class.new(claims(oid: "oid-1", email: "held@justice.gov.uk")).call)
          .to eq user
      end

      it "does not create a new user" do
        create(:user, email: "held@justice.gov.uk", name: "Held", azure_oid: "oid-1")

        expect { described_class.new(claims(oid: "oid-1", email: "held@justice.gov.uk")).call }
          .not_to change(User, :count)
      end

      it "refreshes the name and email from Entra" do
        user = create(:user, email: "old@justice.gov.uk", name: "Old Name", azure_oid: "oid-1")

        described_class.new(
          claims(oid: "oid-1", email: "new@justice.gov.uk", name: "New Name"),
        ).call

        expect(user.reload).to have_attributes(name: "New Name", email: "new@justice.gov.uk")
      end
    end

    context "when no user holds the oid but one matches on email" do
      it "writes the oid to that user" do
        user = create(:user, email: "jane.smith@justice.gov.uk", name: "Jane", azure_oid: nil)

        described_class.new(claims(oid: "oid-1")).call

        expect(user.reload.azure_oid).to eq "oid-1"
      end

      # Review Focus 2: Entra sends "Jane.Smith@...", PQ holds "jane.smith@...".
      # A case-sensitive match would provision a duplicate and then fail the
      # email uniqueness validation.
      it "matches case-insensitively" do
        user = create(:user, email: "jane.smith@justice.gov.uk", name: "Jane", azure_oid: nil)

        result = described_class.new(
          claims(oid: "oid-1", email: "Jane.Smith@justice.gov.uk"),
        ).call

        expect(result.id).to eq user.id
      end

      # Review Focus 5: an email reassigned in the tenant to a different human
      # links that person to the original owner's row. The agreed rule accepts
      # this, so the audit trail is the only thing that makes it recoverable.
      it "logs a warning naming the oid and the user id" do
        user = create(:user, email: "jane.smith@justice.gov.uk", name: "Jane", azure_oid: nil)

        output = warnings_from { described_class.new(claims(oid: "oid-1")).call }

        expect(output).to include("oid-1").and include(user.id.to_s)
      end

      it "does not create a new user" do
        create(:user, email: "jane.smith@justice.gov.uk", name: "Jane", azure_oid: nil)

        expect { described_class.new(claims(oid: "oid-1")).call }
          .not_to change(User, :count)
      end
    end

    context "when the email-matched user already holds a different oid" do
      it "raises IdentityConflict" do
        create(:user, email: "jane.smith@justice.gov.uk", name: "Jane", azure_oid: "oid-existing")

        expect { described_class.new(claims(oid: "oid-new")).call }
          .to raise_error(described_class::IdentityConflict)
      end

      it "leaves the existing azure_oid untouched" do
        user = create(:user, email: "jane.smith@justice.gov.uk", name: "Jane", azure_oid: "oid-existing")

        suppress(described_class::IdentityConflict) do
          described_class.new(claims(oid: "oid-new")).call
        end

        expect(user.reload.azure_oid).to eq "oid-existing"
      end

      it "does not provision a second account for the new identity" do
        create(:user, email: "jane.smith@justice.gov.uk", name: "Jane", azure_oid: "oid-existing")

        expect {
          suppress(described_class::IdentityConflict) do
            described_class.new(claims(oid: "oid-new")).call
          end
        }.not_to change(User, :count)
      end
    end

    context "when nothing matches" do
      it "creates a user with roles PQUSER" do
        result = described_class.new(claims(oid: "oid-new")).call

        expect(result.roles).to eq User::ROLE_PQ_USER
      end

      it "stores the oid, email and name" do
        result = described_class.new(
          claims(oid: "oid-new", email: "new.person@justice.gov.uk", name: "New Person"),
        ).call

        expect(result.reload).to have_attributes(
          azure_oid: "oid-new",
          email: "new.person@justice.gov.uk",
          name: "New Person",
        )
      end

      it "sets a password so the record validates" do
        result = described_class.new(claims(oid: "oid-new")).call

        expect(result.encrypted_password).to be_present
      end

      # A constant or derivable password would be a shared credential across
      # every provisioned account.
      it "gives each provisioned user a different password" do
        first  = described_class.new(claims(oid: "oid-1", email: "one@justice.gov.uk")).call
        second = described_class.new(claims(oid: "oid-2", email: "two@justice.gov.uk")).call

        expect(first.encrypted_password).not_to eq second.encrypted_password
      end
    end

    context "when the matched user is soft deleted" do
      it "undeletes the same row rather than creating a second one" do
        create(:user, email: "jane.smith@justice.gov.uk", name: "Jane",
                      azure_oid: "oid-1", deleted: true)

        expect { described_class.new(claims(oid: "oid-1")).call }
          .not_to change(User, :count)
      end

      it "clears the deleted flag" do
        user = create(:user, email: "jane.smith@justice.gov.uk", name: "Jane",
                             azure_oid: "oid-1", deleted: true)

        described_class.new(claims(oid: "oid-1")).call

        expect(user.reload.deleted).to be false
      end

      it "resets roles to PQUSER even if they were an admin" do
        user = create(:user, email: "jane.smith@justice.gov.uk", name: "Jane",
                             azure_oid: "oid-1", deleted: true,
                             roles: "#{User::ROLE_PQ_USER},#{User::ROLE_ADMIN}")

        described_class.new(claims(oid: "oid-1")).call

        expect(user.reload.roles).to eq User::ROLE_PQ_USER
      end

      # Only a RETURNING removed user is demoted. An active admin signing in
      # normally must keep their role, or the first sign-in after this ships
      # would strip every administrator.
      it "does not demote an active admin" do
        user = create(:user, email: "admin@justice.gov.uk", name: "Admin",
                             azure_oid: "oid-1", deleted: false,
                             roles: "#{User::ROLE_PQ_USER},#{User::ROLE_ADMIN}")

        described_class.new(claims(oid: "oid-1", email: "admin@justice.gov.uk")).call

        expect(user.reload.roles).to eq "#{User::ROLE_PQ_USER},#{User::ROLE_ADMIN}"
      end
    end

    context "when the matched user is locked" do
      # failed_attempts counts failed PASSWORD attempts, which cannot grow once
      # the password route is unmounted, and the unlock route is not mounted
      # either — so a lock from before cutover would strand its owner forever.
      it "clears the lock and returns the user" do
        user = create(:user, email: "jane.smith@justice.gov.uk", name: "Jane",
                             azure_oid: "oid-1", failed_attempts: 9,
                             locked_at: 1.hour.ago, unlock_token: "token")

        result = described_class.new(claims(oid: "oid-1")).call

        expect(result.id).to eq user.id
        expect(user.reload).to have_attributes(
          failed_attempts: 0, locked_at: nil, unlock_token: nil,
        )
      end
    end

    context "when Entra sends no name" do
      it "falls back to the email local part for a new user" do
        result = described_class.new(
          claims(oid: "oid-new", email: "new.person@justice.gov.uk", name: nil),
        ).call

        expect(result.name).to eq "new.person"
      end

      # Syncing a blank name over a good one would be data loss, and the
      # record would fail its presence validation anyway.
      it "keeps an existing user's name rather than clearing it" do
        user = create(:user, email: "jane.smith@justice.gov.uk", name: "Jane Smith", azure_oid: "oid-1")

        described_class.new(claims(oid: "oid-1", name: nil)).call

        expect(user.reload.name).to eq "Jane Smith"
      end
    end

    context "when Entra sends no email at all" do
      it "raises IdentityConflict for a new user" do
        expect { described_class.new(claims(oid: "oid-new", email: nil)).call }
          .to raise_error(described_class::IdentityConflict)
      end

      it "does not create a user" do
        expect {
          suppress(described_class::IdentityConflict) do
            described_class.new(claims(oid: "oid-new", email: nil)).call
          end
        }.not_to change(User, :count)
      end

      # The oid already proves who this is; email is a display field.
      it "still signs in a user whose oid is known" do
        user = create(:user, email: "jane.smith@justice.gov.uk", name: "Jane", azure_oid: "oid-1")

        result = described_class.new(claims(oid: "oid-1", email: nil)).call

        expect(result.id).to eq user.id
        expect(user.reload.email).to eq "jane.smith@justice.gov.uk"
      end
    end

    context "when the synced email collides with another user" do
      let!(:holder) { create(:user, email: "taken@justice.gov.uk", name: "Holder", azure_oid: "oid-holder") }
      let!(:signing_in) { create(:user, email: "mine@justice.gov.uk", name: "Mine", azure_oid: "oid-1") }

      it "returns the oid-matched user signed in" do
        result = described_class.new(
          claims(oid: "oid-1", email: "taken@justice.gov.uk"),
        ).call

        expect(result.id).to eq signing_in.id
      end

      it "leaves the existing email in place" do
        described_class.new(claims(oid: "oid-1", email: "taken@justice.gov.uk")).call

        expect(signing_in.reload.email).to eq "mine@justice.gov.uk"
        expect(holder.reload.email).to eq "taken@justice.gov.uk"
      end

      it "logs a warning" do
        output = warnings_from do
          described_class.new(claims(oid: "oid-1", email: "taken@justice.gov.uk")).call
        end

        expect(output).to include("oid-1")
      end
    end

    # Review Focus 1: a double-clicked handoff button fires two callbacks for a
    # user with no azure_oid. Both pass the email match, both try to write it,
    # and without the rescue the loser turns a successful login into a 500.
    context "when two callbacks race to claim the same oid" do
      it "returns the winning row instead of raising" do
        winner = create(:user, email: "winner@justice.gov.uk", name: "Winner", azure_oid: "oid-race")
        create(:user, email: "jane.smith@justice.gov.uk", name: "Jane", azure_oid: nil)

        result = racing_call

        expect(result.id).to eq winner.id
      end

      it "does not leave a half-written link on the losing row" do
        create(:user, email: "winner@justice.gov.uk", name: "Winner", azure_oid: "oid-race")
        loser = create(:user, email: "jane.smith@justice.gov.uk", name: "Jane", azure_oid: nil)

        racing_call

        expect(loser.reload.azure_oid).to be_nil
      end

      it "does not create a user" do
        create(:user, email: "winner@justice.gov.uk", name: "Winner", azure_oid: "oid-race")
        create(:user, email: "jane.smith@justice.gov.uk", name: "Jane", azure_oid: nil)

        expect { racing_call }.not_to change(User, :count)
      end
    end
  end

  # Simulates the race honestly: the winner's row really is in the table, so
  # our write hits the real unique index and Postgres raises the real
  # RecordNotUnique. Only the "we did not see it when we looked" half is
  # stubbed, which is precisely what a race is.
  def racing_call
    first_lookup = true

    allow(User).to receive(:find_by).and_wrap_original do |original, *args, **kwargs|
      lookup = args.first || kwargs

      if first_lookup && lookup.respond_to?(:key?) && lookup.key?(:azure_oid)
        first_lookup = false
        nil
      else
        original.call(*args, **kwargs)
      end
    end

    described_class.new(
      claims(oid: "oid-race", email: "jane.smith@justice.gov.uk"),
    ).call
  end
end
