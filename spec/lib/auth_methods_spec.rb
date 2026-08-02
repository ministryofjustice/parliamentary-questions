require "rails_helper"

describe AuthMethods do
  describe ".mode" do
    it "defaults to both when AUTH_METHODS is not set" do
      set_auth_methods(nil)
      expect(described_class.mode).to eq("both")
    end

    it "defaults to both when AUTH_METHODS is unrecognised" do
      set_auth_methods("banana")
      expect(described_class.mode).to eq("both")
    end

    it "normalises case and whitespace" do
      set_auth_methods("  SSO_ONLY ")
      expect(described_class.mode).to eq("sso_only")
    end

    %w[both sso_only password_only].each do |mode|
      it "returns #{mode} when AUTH_METHODS=#{mode}" do
        set_auth_methods(mode)
        expect(described_class.mode).to eq(mode)
      end
    end
  end

  describe ".sso_enabled?" do
    it "is true for both" do
      set_auth_methods("both")
      expect(described_class.sso_enabled?).to be(true)
    end

    it "is true for sso_only" do
      set_auth_methods("sso_only")
      expect(described_class.sso_enabled?).to be(true)
    end

    it "is false for password_only" do
      set_auth_methods("password_only")
      expect(described_class.sso_enabled?).to be(false)
    end
  end

  describe ".password_enabled?" do
    it "is true for both" do
      set_auth_methods("both")
      expect(described_class.password_enabled?).to be(true)
    end

    it "is true for password_only" do
      set_auth_methods("password_only")
      expect(described_class.password_enabled?).to be(true)
    end

    it "is false for sso_only" do
      set_auth_methods("sso_only")
      expect(described_class.password_enabled?).to be(false)
    end
  end
end
