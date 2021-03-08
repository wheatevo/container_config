# frozen_string_literal: true

RSpec.describe ContainerConfig::Coercer::SslCertificate do
  subject { described_class.new }

  before do
    allow(File).to receive(:exist?).and_call_original
    allow(File).to receive(:read).and_call_original
  end

  describe "#name" do
    it "returns its name" do
      expect(subject.name).to eq("SSL Certificate")
    end
  end

  describe "#type" do
    it "returns its symbolized type" do
      expect(subject.type).to eq(:ssl_certificate)
    end
  end

  describe "#coerce" do
    let(:cert_file) { "/path/to/cert.crt" }

    # Self-signed SSL cert (localhost CN)
    let(:cert_text) do
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

    context "when certificate file does not exist" do
      it "returns nil" do
        expect(File).to receive(:exist?).with(cert_file).and_return(false)
        expect(subject.coerce(cert_file)).to eq(nil)
      end
    end

    context "when certificate file exists" do
      before do
        allow(File).to receive(:exist?).with(cert_file).and_return(true)
      end

      context "when cert is valid" do
        it "returns the OpenSSL::X509::Certificate" do
          expect(File).to receive(:read).with(cert_file).and_return(cert_text)
          expect(subject.coerce(cert_file)).to be_a(OpenSSL::X509::Certificate)
        end
      end

      context "when cert is invalid" do
        it "returns nil" do
          expect(File).to receive(:read).with(cert_file).and_return("")
          expect(subject.coerce(cert_file)).to eq(nil)
        end
      end
    end
  end
end
