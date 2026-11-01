require "rails_helper"

RSpec.describe AzureOauth::Claims do
  let(:tenant_id) { "tenant-abc" }
  let(:client_id) { "client-abc" }
  let(:issuer)    { "https://login.microsoftonline.com/tenant-abc/v2.0" }

  before do
    allow(Settings).to receive_messages(
      omniauth_azure_tenant_id: tenant_id,
      omniauth_azure_client_id: client_id,
      azure_issuer: issuer,
    )
  end

  # Built as a real OmniAuth::AuthHash, not a plain Hash, so these examples
  # exercise the same Hashie key access the controller will hand over.
  def entra_auth(info: {}, **claims)
    raw_info = {
      "oid" => "00000000-1111-2222-3333-444444444444",
      "tid" => tenant_id,
      "aud" => client_id,
      "iss" => issuer,
      "email" => "jane.smith@justice.gov.uk",
      "name" => "Jane Smith",
    }.merge(claims.transform_keys(&:to_s))

    OmniAuth::AuthHash.new(
      provider: "entra_id",
      uid: raw_info["oid"],
      info: { name: raw_info["name"], email: raw_info["email"] }.merge(info),
      extra: { raw_info: raw_info },
    )
  end

  # The developer strategy carries no raw_info at all: uid is the submitted
  # email and info holds only name and email.
  def developer_auth(uid: "dev.user@justice.gov.uk", **info)
    OmniAuth::AuthHash.new(
      provider: "developer",
      uid: uid,
      info: { name: "Dev User", email: uid }.merge(info),
    )
  end

  describe "#valid?" do
    it "is true for a response from the configured tenant with the configured audience" do
      claims = described_class.new(entra_auth)

      expect(claims).to be_valid
      expect(claims.error).to be_nil
    end

    it "is false when tid does not match the configured tenant" do
      claims = described_class.new(entra_auth(tid: "some-other-tenant"))

      expect(claims).not_to be_valid
      expect(claims.error).to eq :tenant_mismatch
    end

    # aud and iss are NOT re-checked here, and must not be.
    #
    # omniauth-entra-id validates aud, iss, exp and nbf itself, with
    # JWT::Claims.verify_payload! against the id_token — and it does so BEFORE
    # `id_token_data.merge!(auth_token_data)` overwrites those keys with the
    # ACCESS token's values. So the merged raw_info this class reads can carry
    # Graph's app id as aud and the v1 `sts.windows.net` issuer, for any
    # account type whose access token happens to decode. Re-checking them here
    # would refuse every legitimate sign-in, in some tenants and not others.
    #
    # tid is different: it is identical in both tokens, the gem never checks
    # it, and tenant membership is the only access gate — so that check stays
    # and is the only one of its kind in the system.
    it "accepts the access token's audience, which the merge may leave in raw_info" do
      claims = described_class.new(
        entra_auth(aud: "00000003-0000-0000-c000-000000000000"),
      )

      expect(claims).to be_valid
    end

    it "accepts the v1 issuer form, which the merge may leave in raw_info" do
      claims = described_class.new(
        entra_auth(iss: "https://sts.windows.net/#{tenant_id}/"),
      )

      expect(claims).to be_valid
    end

    it "still refuses a response from another tenant" do
      claims = described_class.new(
        entra_auth(tid: "another-tenant",
                   aud: "00000003-0000-0000-c000-000000000000",
                   iss: "https://sts.windows.net/another-tenant/"),
      )

      expect(claims).not_to be_valid
      expect(claims.error).to eq :tenant_mismatch
    end

    it "is false when oid is blank" do
      claims = described_class.new(entra_auth(oid: "   "))

      expect(claims).not_to be_valid
      expect(claims.error).to eq :missing_oid
    end

    it "is false when the oid claim is absent entirely" do
      auth = entra_auth
      auth.extra.raw_info.delete("oid")
      auth.uid = nil

      claims = described_class.new(auth)

      expect(claims).not_to be_valid
      expect(claims.error).to eq :missing_oid
    end

    # Failing closed matters more than convenience here: tenant membership is
    # the only access gate, so an unconfigured tenant must authenticate nobody
    # rather than everybody.
    it "is false when no tenant is configured" do
      allow(Settings).to receive(:omniauth_azure_tenant_id).and_return(nil)

      expect(described_class.new(entra_auth)).not_to be_valid
      expect(described_class.new(entra_auth).error).to eq :tenant_mismatch
    end
  end

  describe "#oid" do
    it "downcases and strips the claim" do
      expect(described_class.new(entra_auth(oid: "  ABC-123  ")).oid).to eq "abc-123"
    end

    it "is nil when the claim is blank" do
      expect(described_class.new(entra_auth(oid: "  ")).oid).to be_nil
    end
  end

  describe "#email" do
    it "returns the email claim when present" do
      expect(described_class.new(entra_auth).email).to eq "jane.smith@justice.gov.uk"
    end

    it "falls back to preferred_username when email is absent" do
      claims = described_class.new(
        entra_auth(email: nil, preferred_username: "jane.smith@justice.gov.uk"),
      )

      expect(claims.email).to eq "jane.smith@justice.gov.uk"
    end

    it "falls back to upn when neither email nor preferred_username is present" do
      claims = described_class.new(
        entra_auth(email: nil, preferred_username: nil, upn: "jane.smith@justice.gov.uk"),
      )

      expect(claims.email).to eq "jane.smith@justice.gov.uk"
    end

    it "is nil when none of the three claims is present" do
      auth = entra_auth(email: nil)
      auth.info.email = nil

      expect(described_class.new(auth).email).to be_nil
    end

    # Deliberately NOT downcased: Task 5 matches case-insensitively, and this
    # value is also written back to the user's record as a display field, so
    # the casing the tenant uses is preserved.
    it "preserves the casing the tenant sent" do
      expect(described_class.new(entra_auth(email: "  Jane.Smith@justice.gov.uk  ")).email)
        .to eq "Jane.Smith@justice.gov.uk"
    end
  end

  describe "#name" do
    it "returns the name claim" do
      expect(described_class.new(entra_auth).name).to eq "Jane Smith"
    end

    it "is nil when absent" do
      auth = entra_auth(name: nil)
      auth.info.name = nil

      expect(described_class.new(auth).name).to be_nil
    end
  end

  describe "with the developer provider" do
    it "is valid on uid alone, with no tenant claims" do
      claims = described_class.new(developer_auth)

      expect(claims).to be_valid
      expect(claims.error).to be_nil
    end

    it "prefixes the oid with 'dev-'" do
      expect(described_class.new(developer_auth(uid: "dev.user@justice.gov.uk")).oid)
        .to eq "dev-dev.user@justice.gov.uk"
    end

    it "normalises the uid before prefixing it" do
      expect(described_class.new(developer_auth(uid: "  Dev.User@Justice.GOV.uk  ")).oid)
        .to eq "dev-dev.user@justice.gov.uk"
    end

    it "reads the email from info, since there is no raw_info" do
      expect(described_class.new(developer_auth).email).to eq "dev.user@justice.gov.uk"
    end

    it "is invalid when the uid is blank" do
      claims = described_class.new(developer_auth(uid: "  "))

      expect(claims).not_to be_valid
      expect(claims.error).to eq :missing_oid
    end

    # A real Entra oid is a GUID and can never begin with "dev-", so a
    # development identity cannot collide with a tenant one.
    it "cannot produce an oid that collides with a real Entra oid" do
      developer = described_class.new(developer_auth(uid: "someone@justice.gov.uk"))
      entra     = described_class.new(entra_auth(oid: "someone@justice.gov.uk"))

      expect(developer.oid).not_to eq entra.oid
    end
  end
end
