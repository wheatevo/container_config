# frozen_string_literal: true

RSpec.describe ContainerConfig::Redis do
  describe "self#load" do
    let(:cert) { double(OpenSSL::X509::Certificate) }
    let(:key) { double(OpenSSL::PKey::RSA) }

    before do
      allow(File).to receive(:exist?).with("/etc/ssl/client.crt").and_return(true)
      allow(File).to receive(:exist?).with("/etc/ssl/client.key").and_return(true)
      allow(File).to receive(:read).with("/etc/ssl/client.crt").and_return("cert_data")
      allow(File).to receive(:read).with("/etc/ssl/client.key").and_return("key_data")

      allow(OpenSSL::X509::Certificate).to receive(:new).with("cert_data").and_return(cert)
      allow(OpenSSL::PKey::RSA).to receive(:new).with("key_data").and_return(key)
    end

    context "when no config is specified" do
      before do
        stub_const("ENV", {})
      end

      it "returns the default config" do
        expect(described_class.load("TEST")).to eq(
          { url: "redis://localhost:6379", password: nil, ssl: false, ssl_params: {} }
        )
      end
    end

    context "when single node config is specified" do
      before do
        stub_const("ENV", { "TEST_HOST" => "test", "TEST_DB" => "3" })
      end

      it "returns the single node config" do
        expect(described_class.load("TEST")).to eq(
          { url: "redis://test:6379", password: nil, ssl: false, ssl_params: {}, db: 3 }
        )
      end
    end

    context "when single node config is specified with an empty password" do
      before do
        stub_const("ENV", { "TEST_HOST" => "test", "TEST_PASSWORD" => "" })
      end

      it "returns the single node config with password set to nil" do
        expect(described_class.load("TEST")).to eq(
          { url: "redis://test:6379", password: nil, ssl: false, ssl_params: {} }
        )
      end
    end

    context "when single node config is specified with SSL parameters" do
      before do
        stub_const("ENV", {
                     "TEST_HOST" => "test",
                     "TEST_PASSWORD" => "test",
                     "TEST_SSL" => true,
                     "TEST_SSL_CA_FILE" => "/etc/ssl/ca.crt",
                     "TEST_SSL_CA_PATH" => "/etc/ssl/ca_dir",
                     "TEST_SSL_CERT" => "/etc/ssl/client.crt",
                     "TEST_SSL_KEY" => "/etc/ssl/client.key",
                     "TEST_SSL_VERIFY_MODE" => "VERIFY_PEER"
                   })
      end

      it "returns the single node config with SSL parameters populated" do
        expect(described_class.load("TEST")).to eq(
          {
            url: "redis://test:6379",
            password: "test",
            ssl: true,
            ssl_params: {
              ca_file: "/etc/ssl/ca.crt",
              ca_path: "/etc/ssl/ca_dir",
              cert: cert,
              key: key,
              verify_mode: OpenSSL::SSL::VERIFY_PEER
            }
          }
        )
      end
    end

    context "when sentinel config is specified with password" do
      before do
        stub_const("ENV", {
                     "TEST_HOST" => "test",
                     "TEST_PORT" => "1234",
                     "TEST_PASSWORD" => "redispass",
                     "TEST_SENTINELS" => "sentinel1,sentinel2",
                     "TEST_SENTINEL_PORT" => "12345",
                     "TEST_SENTINEL_PASSWORD" => "sentinelpass"
                   })
      end

      it "returns the HA config" do
        expect(described_class.load("TEST")).to eq(
          {
            url: "redis://test:1234",
            password: "redispass",
            sentinels: [
              { host: "sentinel1", port: "12345", password: "sentinelpass", ssl_params: {} },
              { host: "sentinel2", port: "12345", password: "sentinelpass", ssl_params: {} }
            ],
            ssl: false,
            ssl_params: {}
          }
        )
      end
    end

    context "when sentinel config is specified with empty password" do
      before do
        stub_const("ENV", {
                     "TEST_HOST" => "test",
                     "TEST_PORT" => "1234",
                     "TEST_PASSWORD" => "redispass",
                     "TEST_SENTINELS" => "sentinel1,sentinel2",
                     "TEST_SENTINEL_PORT" => "12345",
                     "TEST_SENTINEL_PASSWORD" => ""
                   })
      end

      it "returns the HA config with password set to nil" do
        expect(described_class.load("TEST")).to eq(
          {
            url: "redis://test:1234",
            password: "redispass",
            sentinels: [
              { host: "sentinel1", port: "12345", password: nil, ssl_params: {} },
              { host: "sentinel2", port: "12345", password: nil, ssl_params: {} }
            ],
            ssl: false,
            ssl_params: {}
          }
        )
      end
    end

    context "when sentinel config is specified with SSL parameters" do
      let(:sentinel_cert) { double(OpenSSL::X509::Certificate) }
      let(:sentinel_key) { double(OpenSSL::PKey::RSA) }

      before do
        stub_const("ENV", {
                     "TEST_HOST" => "test",
                     "TEST_PASSWORD" => "test",
                     "TEST_SSL" => true,
                     "TEST_SSL_CA_FILE" => "/etc/ssl/ca.crt",
                     "TEST_SSL_CA_PATH" => "/etc/ssl/ca_dir",
                     "TEST_SSL_CERT" => "/etc/ssl/client.crt",
                     "TEST_SSL_KEY" => "/etc/ssl/client.key",
                     "TEST_SSL_VERIFY_MODE" => "VERIFY_PEER",
                     "TEST_SENTINELS" => "sentinel1,sentinel2",
                     "TEST_SENTINEL_PORT" => "12345",
                     "TEST_SENTINEL_PASSWORD" => "testsentinel",
                     "TEST_SENTINEL_SSL" => true,
                     "TEST_SENTINEL_SSL_CA_FILE" => "/etc/ssl/ca_sentinel.crt",
                     "TEST_SENTINEL_SSL_CA_PATH" => "/etc/ssl/ca_sentinel_dir",
                     "TEST_SENTINEL_SSL_CERT" => "/etc/ssl/client_sentinel.crt",
                     "TEST_SENTINEL_SSL_KEY" => "/etc/ssl/client_sentinel.key",
                     "TEST_SENTINEL_SSL_VERIFY_MODE" => "VERIFY_PEER"
                   })

        allow(File).to receive(:exist?).with("/etc/ssl/client_sentinel.crt").and_return(true)
        allow(File).to receive(:exist?).with("/etc/ssl/client_sentinel.key").and_return(true)
        allow(File).to receive(:read).with("/etc/ssl/client_sentinel.crt").and_return("sentinel_cert_data")
        allow(File).to receive(:read).with("/etc/ssl/client_sentinel.key").and_return("sentinel_key_data")

        allow(OpenSSL::X509::Certificate).to receive(:new).with("sentinel_cert_data").and_return(sentinel_cert)
        allow(OpenSSL::PKey::RSA).to receive(:new).with("sentinel_key_data").and_return(sentinel_key)
      end

      it "returns the single node config with SSL parameters populated" do
        expect(described_class.load("TEST")).to eq(
          {
            url: "redis://test:6379",
            password: "test",
            sentinels: [
              {
                host: "sentinel1",
                port: "12345",
                password: "testsentinel",
                ssl_params: {
                  ca_file: "/etc/ssl/ca_sentinel.crt",
                  ca_path: "/etc/ssl/ca_sentinel_dir",
                  cert: sentinel_cert,
                  key: sentinel_key,
                  verify_mode: OpenSSL::SSL::VERIFY_PEER
                }
              },
              {
                host: "sentinel2",
                port: "12345",
                password: "testsentinel",
                ssl_params: {
                  ca_file: "/etc/ssl/ca_sentinel.crt",
                  ca_path: "/etc/ssl/ca_sentinel_dir",
                  cert: sentinel_cert,
                  key: sentinel_key,
                  verify_mode: OpenSSL::SSL::VERIFY_PEER
                }
              }
            ],
            ssl: true,
            ssl_params: {
              ca_file: "/etc/ssl/ca.crt",
              ca_path: "/etc/ssl/ca_dir",
              cert: cert,
              key: key,
              verify_mode: OpenSSL::SSL::VERIFY_PEER
            }
          }
        )
      end
    end
  end
end
