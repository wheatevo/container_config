# frozen_string_literal: true

RSpec.describe ContainerConfig::Provider::RailsCredential do
  subject { described_class.new }

  describe "#name" do
    it "returns its name" do
      expect(subject.name).to eq("Rails Credential")
    end
  end

  describe "#load" do
    let(:rails_creds) { { test: { var: "from_creds" } } }

    before do
      allow(Rails).to receive(:application).and_return(double(credentials: double(config: rails_creds)))
    end

    it "returns the Rails credential value" do
      expect(subject.load("NOTHING", "nothing")).to eq(nil)
      expect(subject.load("TEST_VAR", "test", "var")).to eq("from_creds")
    end

    context "when Rails.application is nil" do
      before do
        allow(Rails).to receive(:application).and_return(nil)
      end

      it "returns nil" do
        expect(subject.load("NOTHING")).to eq(nil)
        expect(subject.load("TEST_VAR")).to eq(nil)
      end
    end
  end
end
