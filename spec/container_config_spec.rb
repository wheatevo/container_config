# frozen_string_literal: true

RSpec.describe ContainerConfig do
  before do
    allow(File).to receive(:exist?).and_call_original
    allow(File).to receive(:read).and_call_original

    # Clear the value cache before each run
    described_class.clear_cache

    # Clear the coercer cache before each run
    described_class.coercers = nil

    # Clear the provider cache before each run
    described_class.providers = nil
  end

  it "has a version number" do
    expect(ContainerConfig::VERSION).not_to be nil
  end

  describe "self#load" do
    let(:types) { %i[boolean integer string symbol ssl_verify_mode ssl_certificate ssl_key] }
    let(:rails_creds) { {} }

    context "when missing config value" do
      before do
        stub_const("ENV", {})
      end

      context "when required is true" do
        it "raises an exception" do
          expect { described_class.load("MY_VAR", required: true) }.to raise_error(ContainerConfig::MissingRequiredValue)
        end
      end

      context "when required is false" do
        it "returns nil" do
          expect(described_class.load("MY_VAR")).to eq(nil)
        end
      end

      context "when coerce_nil is false and type is specified" do
        it "returns nil" do
          types.each do |value_type|
            expect(described_class.load("MY_VAR", coerce_nil: false, type: value_type)).to eq(nil)
          end
        end
      end

      context "when coerce_nil is true and type is specified" do
        let(:type_returns) do
          {
            boolean: false,
            integer: 0,
            string: "",
            symbol: nil,
            ssl_verify_mode: nil,
            ssl_certificate: nil,
            ssl_key: nil
          }
        end

        it "returns a coerced value" do
          types.each do |value_type|
            expect(described_class.load("MY_VAR", coerce_nil: true, type: value_type)).to eq(type_returns[value_type])
          end
        end
      end
    end

    context "when config value is specified in the environment variables and Rails credentials" do
      let(:rails_creds) { { test: { var: "from_creds" } } }

      before do
        stub_const("ENV", { "TEST_VAR" => "from_env" })
        allow(Rails).to receive(:application).and_return(double(credentials: double(config: rails_creds)))
      end

      it "returns environment variable value" do
        expect(described_class.load("TEST_VAR", "test", "var", raise: true)).to eq("from_env")
      end
    end

    context "when config value is only specified in Rails credentials" do
      let(:rails_creds) { { test: { var: "from_creds" } } }

      before do
        stub_const("ENV", {})
        allow(Rails).to receive(:application).and_return(double(credentials: double(config: rails_creds)))
      end

      it "returns Rails credential value" do
        expect(described_class.load("TEST_VAR", "test", "var", raise: true)).to eq("from_creds")
      end
    end

    context "when config value is specified in mounted secret file" do
      before do
        stub_const("ENV", {})
        allow(Dir).to receive(:glob).with("/etc/*-secrets/**/TEST_VAR").and_return(["/etc/*-secrets/TEST_VAR"])
        allow(File).to receive(:exist?).with("/etc/*-secrets/TEST_VAR").and_return(true)
        allow(File).to receive(:read).with("/etc/*-secrets/TEST_VAR").and_return("from_secret_file")
      end

      it "returns secret file value" do
        expect(described_class.load("TEST_VAR", "test", "var", raise: true)).to eq("from_secret_file")
      end
    end

    context "when config value is specified as a string and type is specified" do
      # Self-signed SSL key (localhost CN)
      let(:ssl_key) do
        <<~KEY
          -----BEGIN RSA PRIVATE KEY-----
          MIICXgIBAAKBgQDiRWN5cjVIfKADvyRj+7gsN9p4dXoj3Sj3nuHjI/GA8/Nko2I0
          EJEA5ENOwl94o+E09UFOc7R2KhWcq5fg+DRSuM6GE6edMWltDnaMZvDBiMeKWtkB
          iVt6duUvhCuvxrfJ6ixCDiBAXX24OrVBKcbvt/ePK40DN3/7lsTH71TDywIDAQAB
          AoGBAJajmYEt/rk+dw1ngKOr3sZZfPI7S9B6mZ6ZQUuGD29Jeh3jBCsjaFYOoZza
          nNLlT7aBHTRMpbUReYfvWVLmC3ZSZK1VmbBErEZBZar433U5H8FM/MxRWPotBBhy
          I5bFPMnyRklX38H77PNkaZNf+P+o1j5bnNvWdwGlSYFeWAcRAkEA+she3kmX6xKG
          q1AZaRZOce5sWsIHwfNn+Skyoc37ImqbAlTE/XRfx2VQ1F5IdARVHMu367RdmTiY
          chXjPjYueQJBAOb6eQiO0ghh7Nlm5/jwli8+rd7GLhL4jDdM9N+2ueZmc/bj5npI
          phugL2S285WlUOsn8xjMK5Sgvzfu5ZWoY2MCQQCkuBNH4gK8zlBSGax3D8W6o6Xb
          /vHlfKDgUSUGjirTsj3aTB+Pcm6uo2dx9fOU8HuPDGfjk3ae+0N2O9YkuKXRAkEA
          zsI9n8yA9KH762vzkOKD/cykxXsveSnmEgagWLXv2O+zNLky8hmgH7CXXBdtGnK+
          aZH8SSFSjZwLL515BCuUswJATTFnXn41qC4JENsbYL8alQwZZq9IWsn00uHAIDDE
          uYRGGFIZKYSRbFXENYE7Wixcc3eewSyYU2sD2dq9BAdMuw==
          -----END RSA PRIVATE KEY-----
        KEY
      end

      # Self-signed SSL cert (localhost CN)
      let(:ssl_cert) do
        <<~CERT
          -----BEGIN CERTIFICATE-----
          MIICPTCCAaagAwIBAgIBATANBgkqhkiG9w0BAQsFADAUMRIwEAYDVQQDDAlsb2Nh
          bGhvc3QwHhcNMjEwMzA4MTcxMzQ4WhcNMjIwMzA4MTcxMzQ4WjAUMRIwEAYDVQQD
          DAlsb2NhbGhvc3QwgZ8wDQYJKoZIhvcNAQEBBQADgY0AMIGJAoGBAOJFY3lyNUh8
          oAO/JGP7uCw32nh1eiPdKPee4eMj8YDz82SjYjQQkQDkQ07CX3ij4TT1QU5ztHYq
          FZyrl+D4NFK4zoYTp50xaW0Odoxm8MGIx4pa2QGJW3p25S+EK6/Gt8nqLEIOIEBd
          fbg6tUEpxu+3948rjQM3f/uWxMfvVMPLAgMBAAGjgZ4wgZswCQYDVR0TBAIwADAL
          BgNVHQ8EBAMCA7gwHQYDVR0OBBYEFBQRNzwcWMs5vJbvG5jeQJRlQpDbMBMGA1Ud
          JQQMMAoGCCsGAQUFBwMBMA8GCWCGSAGG+EIBDQQCFgAwPAYDVR0jBDUwM4AUFBE3
          PBxYyzm8lu8bmN5AlGVCkNuhGKQWMBQxEjAQBgNVBAMMCWxvY2FsaG9zdIIBATAN
          BgkqhkiG9w0BAQsFAAOBgQCyyU1CeV9omARj0H9ZDYjOybXMtTMTKQ+2kgTzWAG+
          w8YAZcYVz4Py2u8eHsQq9Oe+g2Kog4XEiTzSc1OqGEcT34pDjjlowxVi/FxBgQVo
          qxhSkp+kPU8NE5f7llSJAgeJA2yGNE0mGmjd56Je07d4PCa4uK1kCPpxOkKiD6Q0
          6g==
          -----END CERTIFICATE-----
        CERT
      end

      let(:expected_values) do
        {
          "STRING_TRUE" => { type: :boolean, value: true },
          "STRING_FALSE" => { type: :boolean, value: false },
          "STRING_100" => { type: :integer, value: 100 },
          "STRING_SYMBOL" => { type: :symbol, value: :my_symbol },
          "STRING_VERIFY_MODE" => { type: :ssl_verify_mode, value: OpenSSL::SSL::VERIFY_PEER },
          "STRING_SSL_CERT" => { type: :ssl_certificate, value: ssl_cert, class: OpenSSL::X509::Certificate },
          "STRING_SSL_KEY" => { type: :ssl_key, value: ssl_key, class: OpenSSL::PKey::RSA }
        }
      end

      before do
        stub_const("ENV", {
                     "STRING_TRUE" => "true",
                     "STRING_FALSE" => "false",
                     "STRING_100" => "100",
                     "STRING_SYMBOL" => "my_symbol",
                     "STRING_VERIFY_MODE" => "VERIFY_PEER",
                     "STRING_SSL_CERT" => "/etc/ssl/localhost.crt",
                     "STRING_SSL_KEY" => "/etc/ssl/localhost.key"
                   })

        allow(File).to receive(:exist?).with("/etc/ssl/localhost.crt").and_return(true)
        allow(File).to receive(:exist?).with("/etc/ssl/localhost.key").and_return(true)
        allow(File).to receive(:read).with("/etc/ssl/localhost.crt").and_return(ssl_cert)
        allow(File).to receive(:read).with("/etc/ssl/localhost.key").and_return(ssl_key)
      end

      it "coerces the value appropriately" do
        expected_values.each do |env_key, result_data|
          coerced_value = described_class.load(env_key, type: result_data[:type])

          if %i[ssl_certificate ssl_key].include?(result_data[:type])
            expect(coerced_value).to be_a(result_data[:class])
            expect(coerced_value.to_s).to eq(result_data[:value].to_s)
          else
            expect(coerced_value).to eq(result_data[:value])
          end
        end
      end
    end

    context "when config value is listed in the provided enum" do
      before do
        stub_const("ENV", { "TEST_VAR" => "from_env" })
      end

      it "does not raise an exception" do
        config_value = described_class.load("TEST_VAR", enum: %w[from_env another_val more_values])
        expect(config_value).to eq("from_env")
      end
    end

    context "when config value is not listed in the provided enum" do
      before do
        stub_const("ENV", { "TEST_VAR" => "from_env" })
      end

      it "raises an exception" do
        expect { described_class.load("TEST_VAR", enum: %w[another_val more_values]) }.to raise_error(
          ContainerConfig::InvalidEnumValue
        )
      end
    end

    context "when cache is set" do
      it "caches the value" do
        stub_const("ENV", { "TEST_VAR" => "cached_value" })
        expect(described_class.load("TEST_VAR", cache: true)).to eq("cached_value")
        stub_const("ENV", { "TEST_VAR" => "uncached_value" })
        expect(described_class.load("TEST_VAR", cache: true)).to eq("cached_value")
        expect(described_class.load("TEST_VAR", cache: false)).to eq("uncached_value")
        expect(described_class.cache).to_not be_empty
      end
    end

    context "when cache is not set" do
      it "does not cache the value" do
        stub_const("ENV", { "TEST_VAR" => "uncached_value" })
        expect(described_class.load("TEST_VAR", cache: false)).to eq("uncached_value")
        expect(described_class.cache).to be_empty
      end
    end
  end

  describe "self#coercers" do
    it "returns cached coercers" do
      coercers = described_class.coercers
      expect(coercers.count).to eq(8)
      expect(coercers).to eq(described_class.coercers)
    end
  end

  describe "self#coercers=" do
    it "replaces current coercers" do
      described_class.coercers = []
      expect(described_class.coercers).to eq([])
    end
  end

  describe "self#providers" do
    it "returns cached providers" do
      providers = described_class.providers
      expect(providers.count).to eq(3)
      expect(providers).to eq(described_class.providers)
    end
  end

  describe "self#providers=" do
    it "replaces current providers" do
      described_class.providers = []
      expect(described_class.providers).to eq([])
    end
  end

  describe "self#logger" do
    it "returns the cached logger" do
      expect(described_class.logger).to be_a(described_class::Logger)
      expect(described_class.logger).to eq(described_class.logger)
    end
  end

  describe "self#logger=" do
    let(:logger) { ::Logger.new($stdout) }
    it "replaces the current logger" do
      described_class.logger = logger
      expect(described_class.logger).to eq(logger)
    end
  end

  describe "self#log_formatter" do
    it "returns the cached log formatter" do
      expect(described_class.log_formatter).to eq(described_class.logger.formatter)
    end
  end

  describe "self#log_formatter=" do
    let(:formatter) { ::Logger::Formatter.new }

    it "replaces the cached log formatter" do
      original_formatter = described_class.log_formatter
      described_class.log_formatter = formatter
      expect(described_class.log_formatter).to eq(formatter)
      expect(original_formatter).to_not eq(formatter)
    end
  end

  describe "self#rails_app?" do
    context "when in a rails app" do
      before do
        allow(Rails).to receive(:application)
      end

      it "returns true" do
        expect(described_class.rails_app?).to eq(true)
      end
    end

    context "when not in a rails app" do
      it "returns false" do
        expect(described_class.rails_app?).to eq(false)
      end
    end
  end
end
