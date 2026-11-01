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
#  azure_oid              :string
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

  describe "azure_oid" do
    it { is_expected.to have_db_column(:azure_oid).of_type(:string) }
    it { is_expected.to have_db_index(:azure_oid).unique(true) }

    # The declared index above is what Task 5's trust-on-first-use link relies
    # on to be unclaimable twice, so prove the database actually refuses the
    # second claim rather than only that the index is declared.
    it "refuses two users claiming the same oid" do
      create(:user, email: "first@example.com", azure_oid: "oid-shared")

      expect { create(:user, email: "second@example.com", azure_oid: "oid-shared") }
        .to raise_error(ActiveRecord::RecordNotUnique)
    end

    # Equally load-bearing, and the opposite risk: every row predating OAuth
    # has no oid, so the unique index must tolerate many NULLs. Postgres does,
    # but a later well-meant `null: false` or a change of index type would
    # lock everyone but one user out.
    it "allows many users to have no oid" do
      create(:user, email: "first@example.com", azure_oid: nil)

      expect { create(:user, email: "second@example.com", azure_oid: nil) }
        .not_to raise_error
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
