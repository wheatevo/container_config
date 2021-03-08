# frozen_string_literal: true

RSpec.describe ContainerConfig::Coercer::SslVerifyMode do
  subject { described_class.new }

  describe "#name" do
    it "returns its name" do
      expect(subject.name).to eq("SSL Verification Mode")
    end
  end

  describe "#type" do
    it "returns its symbolized type" do
      expect(subject.type).to eq(:ssl_verify_mode)
    end
  end

  describe "#coerce" do
    context "when mode is valid" do
      it "returns the mode's value" do
        expect(subject.coerce("VERIFY_NONE")).to eq(OpenSSL::SSL::VERIFY_NONE)
        expect(subject.coerce("VERIFY_PEER")).to eq(OpenSSL::SSL::VERIFY_PEER)
        expect(subject.coerce("VERIFY_FAIL_IF_NO_PEER_CERT")).to eq(OpenSSL::SSL::VERIFY_FAIL_IF_NO_PEER_CERT)
        expect(subject.coerce("VERIFY_CLIENT_ONCE")).to eq(OpenSSL::SSL::VERIFY_CLIENT_ONCE)
      end
    end

    context "when mode is invalid" do
      it "returns nil" do
        expect(subject.coerce("Junk")).to eq(nil)
        expect(subject.coerce("VERIFY_SOME")).to eq(nil)
        expect(subject.coerce("VERIFY_OTHER")).to eq(nil)
        expect(subject.coerce(123)).to eq(nil)
        expect(subject.coerce(:a_sym)).to eq(nil)
        expect(subject.coerce(["testing"])).to eq(nil)
        expect(subject.coerce(nil)).to eq(nil)
      end
    end
  end
end
