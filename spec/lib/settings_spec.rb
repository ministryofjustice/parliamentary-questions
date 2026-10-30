require "spec_helper"

RSpec.describe Settings do
  # climate_control is not in the bundle, so stash and restore the keys each
  # example touches. Mutating ENV after boot and still seeing the new value is
  # also what proves these accessors read ENV lazily rather than freezing it at
  # load time, the way the eager @pq_rest_api does.
  def with_env(**vars)
    original = vars.to_h { |key, _value| [key.to_s, ENV.fetch(key.to_s, nil)] }
    vars.each { |key, value| write_env(key.to_s, value) }
    yield
  ensure
    original.each { |key, value| write_env(key, value) }
  end

  def write_env(key, value)
    if value.nil?
      ENV.delete(key)
    else
      ENV[key] = value
    end
  end

  describe ".oauth_azure_enabled?" do
    it "defaults to true when unset" do
      with_env(OAUTH_AZURE_ENABLED: nil) do
        expect(described_class.oauth_azure_enabled?).to be true
      end
    end

    it "is false when OAUTH_AZURE_ENABLED is 'false'" do
      with_env(OAUTH_AZURE_ENABLED: "false") do
        expect(described_class.oauth_azure_enabled?).to be false
      end
    end

    it "is true when OAUTH_AZURE_ENABLED is 'true'" do
      with_env(OAUTH_AZURE_ENABLED: "true") do
        expect(described_class.oauth_azure_enabled?).to be true
      end
    end

    it "defaults to true when the variable is set but empty" do
      with_env(OAUTH_AZURE_ENABLED: "") do
        expect(described_class.oauth_azure_enabled?).to be true
      end
    end
  end

  describe ".password_login_enabled?" do
    it "defaults to true when unset" do
      with_env(PASSWORD_LOGIN_ENABLED: nil) do
        expect(described_class.password_login_enabled?).to be true
      end
    end

    it "is false when PASSWORD_LOGIN_ENABLED is 'false'" do
      with_env(PASSWORD_LOGIN_ENABLED: "false") do
        expect(described_class.password_login_enabled?).to be false
      end
    end
  end

  describe ".omniauth_azure_tenant_id" do
    it "returns the configured tenant id" do
      with_env(OMNIAUTH_AZURE_TENANT_ID: "tenant-abc") do
        expect(described_class.omniauth_azure_tenant_id).to eq "tenant-abc"
      end
    end

    it "is nil when unset" do
      with_env(OMNIAUTH_AZURE_TENANT_ID: nil) do
        expect(described_class.omniauth_azure_tenant_id).to be_nil
      end
    end
  end

  describe ".omniauth_azure_client_id" do
    it "returns the configured client id" do
      with_env(OMNIAUTH_AZURE_CLIENT_ID: "client-abc") do
        expect(described_class.omniauth_azure_client_id).to eq "client-abc"
      end
    end

    it "is nil when unset" do
      with_env(OMNIAUTH_AZURE_CLIENT_ID: nil) do
        expect(described_class.omniauth_azure_client_id).to be_nil
      end
    end
  end

  describe ".omniauth_azure_client_secret" do
    it "returns the configured client secret" do
      with_env(OMNIAUTH_AZURE_CLIENT_SECRET: "shhh") do
        expect(described_class.omniauth_azure_client_secret).to eq "shhh"
      end
    end

    it "is nil when unset" do
      with_env(OMNIAUTH_AZURE_CLIENT_SECRET: nil) do
        expect(described_class.omniauth_azure_client_secret).to be_nil
      end
    end
  end

  describe ".azure_issuer" do
    it "builds the v2.0 issuer URL from the tenant id" do
      with_env(OMNIAUTH_AZURE_TENANT_ID: "tenant-abc") do
        expect(described_class.azure_issuer)
          .to eq "https://login.microsoftonline.com/tenant-abc/v2.0"
      end
    end
  end

  describe ".validate_azure_credentials!" do
    it "does not raise when all three credentials are present in production" do
      with_env(RAILS_ENV: "production", OAUTH_AZURE_ENABLED: "true",
               OMNIAUTH_AZURE_TENANT_ID: "tenant-abc",
               OMNIAUTH_AZURE_CLIENT_ID: "client-abc",
               OMNIAUTH_AZURE_CLIENT_SECRET: "shhh") do
        expect { described_class.validate_azure_credentials! }.not_to raise_error
      end
    end

    it "raises when the tenant id is missing in production" do
      with_env(RAILS_ENV: "production", OAUTH_AZURE_ENABLED: "true",
               OMNIAUTH_AZURE_TENANT_ID: nil,
               OMNIAUTH_AZURE_CLIENT_ID: "client-abc",
               OMNIAUTH_AZURE_CLIENT_SECRET: "shhh") do
        expect { described_class.validate_azure_credentials! }
          .to raise_error(/OMNIAUTH_AZURE_TENANT_ID/)
      end
    end

    it "raises when the client id is missing in production" do
      with_env(RAILS_ENV: "production", OAUTH_AZURE_ENABLED: "true",
               OMNIAUTH_AZURE_TENANT_ID: "tenant-abc",
               OMNIAUTH_AZURE_CLIENT_ID: nil,
               OMNIAUTH_AZURE_CLIENT_SECRET: "shhh") do
        expect { described_class.validate_azure_credentials! }
          .to raise_error(/OMNIAUTH_AZURE_CLIENT_ID/)
      end
    end

    it "raises when the client secret is missing in production" do
      with_env(RAILS_ENV: "production", OAUTH_AZURE_ENABLED: "true",
               OMNIAUTH_AZURE_TENANT_ID: "tenant-abc",
               OMNIAUTH_AZURE_CLIENT_ID: "client-abc",
               OMNIAUTH_AZURE_CLIENT_SECRET: nil) do
        expect { described_class.validate_azure_credentials! }
          .to raise_error(/OMNIAUTH_AZURE_CLIENT_SECRET/)
      end
    end

    it "treats a blank credential as missing" do
      with_env(RAILS_ENV: "production", OAUTH_AZURE_ENABLED: "true",
               OMNIAUTH_AZURE_TENANT_ID: "  ",
               OMNIAUTH_AZURE_CLIENT_ID: "client-abc",
               OMNIAUTH_AZURE_CLIENT_SECRET: "shhh") do
        expect { described_class.validate_azure_credentials! }
          .to raise_error(/OMNIAUTH_AZURE_TENANT_ID/)
      end
    end

    it "does not raise outside production even with no credentials" do
      with_env(RAILS_ENV: "test", OAUTH_AZURE_ENABLED: "true",
               OMNIAUTH_AZURE_TENANT_ID: nil,
               OMNIAUTH_AZURE_CLIENT_ID: nil,
               OMNIAUTH_AZURE_CLIENT_SECRET: nil) do
        expect { described_class.validate_azure_credentials! }.not_to raise_error
      end
    end

    it "does not raise in production when OAuth is disabled" do
      with_env(RAILS_ENV: "production", OAUTH_AZURE_ENABLED: "false",
               OMNIAUTH_AZURE_TENANT_ID: nil,
               OMNIAUTH_AZURE_CLIENT_ID: nil,
               OMNIAUTH_AZURE_CLIENT_SECRET: nil) do
        expect { described_class.validate_azure_credentials! }.not_to raise_error
      end
    end

    # Pinned as a positive match on the whole message rather than as a negative
    # "does not include the value" assertion: a bare negative is satisfied by
    # any unrelated error, so it would pass before the method even exists.
    it "names only the missing variable, never any credential's value" do
      with_env(RAILS_ENV: "production", OAUTH_AZURE_ENABLED: "true",
               OMNIAUTH_AZURE_TENANT_ID: "tenant-abc",
               OMNIAUTH_AZURE_CLIENT_ID: "client-abc",
               OMNIAUTH_AZURE_CLIENT_SECRET: nil) do
        expect { described_class.validate_azure_credentials! }
          .to raise_error(
            RuntimeError,
            "Cannot find environment variable OMNIAUTH_AZURE_CLIENT_SECRET. Please set it first",
          )
      end
    end
  end
end
