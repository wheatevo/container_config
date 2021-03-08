# frozen_string_literal: true

RSpec.describe ContainerConfig::Coercer::SslKey do
  subject { described_class.new }

  before do
    allow(File).to receive(:exist?).and_call_original
    allow(File).to receive(:read).and_call_original
  end

  describe "#name" do
    it "returns its name" do
      expect(subject.name).to eq("SSL Private Key")
    end
  end

  describe "#type" do
    it "returns its symbolized type" do
      expect(subject.type).to eq(:ssl_key)
    end
  end

  describe "#coerce" do
    let(:key_file) { "/path/to/cert.key" }

    # Self-signed SSL key (localhost CN)
    let(:key_text) do
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

    context "when key file does not exist" do
      it "returns nil" do
        expect(File).to receive(:exist?).with(key_file).and_return(false)
        expect(subject.coerce(key_file)).to eq(nil)
      end
    end

    context "when key file exists" do
      before do
        allow(File).to receive(:exist?).with(key_file).and_return(true)
      end

      context "when key is valid" do
        it "returns the OpenSSL::PKey::RSA" do
          expect(File).to receive(:read).with(key_file).and_return(key_text)
          expect(subject.coerce(key_file)).to be_a(OpenSSL::PKey::RSA)
        end
      end

      context "when key is invalid" do
        it "returns nil" do
          expect(File).to receive(:read).with(key_file).and_return("")
          expect(subject.coerce(key_file)).to eq(nil)
        end
      end
    end
  end
end
