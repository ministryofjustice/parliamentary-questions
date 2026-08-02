# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  email                  :string           default(""), not null
#  encrypted_password     :string           default("")
#  reset_password_token   :string
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default(0), not null
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :string
#  last_sign_in_ip        :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  name                   :string
#  invitation_token       :string
#  invitation_created_at  :datetime
#  invitation_sent_at     :datetime
#  invitation_accepted_at :datetime
#  invitation_limit       :integer
#  invited_by_type        :string
#  invited_by_id          :integer
#  invitations_count      :integer          default(0)
#  roles                  :string
#  deleted                :boolean          default(FALSE)
#  failed_attempts        :integer          default(0)
#  unlock_token           :string
#  locked_at              :datetime
#

require "rails_helper"

describe User do
  let(:user) { build(:user) }

  it "passes factory build" do
    expect(user).to be_valid
  end

  it "provides a method for authentication" do
    expect(user.active_for_authentication?).to be(true)
  end

  describe ".from_omniauth" do
    let(:email) { "existing.user@justice.gov.uk" }

    def auth_hash(email:, name: "Azure Name")
      OmniAuth::AuthHash.new(
        "provider" => "entra_id",
        "uid" => "11111111-2222-3333-4444-555555555555",
        "info" => { "email" => email, "name" => name },
      )
    end

    context "when a user with a matching email exists" do
      let!(:existing) { create(:user, email:) }

      it "returns the user" do
        expect(described_class.from_omniauth(auth_hash(email:))).to eq(existing)
      end

      it "matches case-insensitively" do
        expect(described_class.from_omniauth(auth_hash(email: email.upcase))).to eq(existing)
      end

      it "returns soft-deleted users so callers can reject them" do
        existing.update!(deleted: true)
        expect(described_class.from_omniauth(auth_hash(email:))).to eq(existing)
      end
    end

    context "when no matching user exists" do
      it "creates a PQ user from the Azure profile" do
        user = described_class.from_omniauth(auth_hash(email: "new.user@justice.gov.uk", name: "New User"))

        expect(user).to be_persisted
        expect(user.email).to eq("new.user@justice.gov.uk")
        expect(user.name).to eq("New User")
        expect(user.roles).to eq(User::ROLE_PQ_USER)
      end

      it "downcases the stored email" do
        user = described_class.from_omniauth(auth_hash(email: "New.User@Justice.gov.uk"))
        expect(user.email).to eq("new.user@justice.gov.uk")
      end

      it "falls back to the email local part when Azure provides no name" do
        user = described_class.from_omniauth(auth_hash(email: "new.user@justice.gov.uk", name: nil))
        expect(user.name).to eq("new.user")
      end
    end

    it "returns nil when the auth hash has no email" do
      expect(described_class.from_omniauth(auth_hash(email: nil))).to be_nil
      expect(described_class.from_omniauth(auth_hash(email: "  "))).to be_nil
    end
  end

  describe "validations" do
    it "requires a name" do
      user.name = nil
      expect(user).to be_invalid
    end

    it "requires an email" do
      user.email = nil
      expect(user).to be_invalid
    end

    it "requires a valid email" do
      user.email = "colin"
      expect(user).to be_invalid
    end

    it "requires a role" do
      user.roles = nil
      expect(user).to be_invalid
    end
  end
end
