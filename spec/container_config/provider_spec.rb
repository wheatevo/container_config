# frozen_string_literal: true

RSpec.describe ContainerConfig::Provider do
  describe "self#load_value" do
    context "when no providers contain the value" do
      it "returns nil" do
        expect(described_class.load_value("NOVALUE")).to eq(nil)
      end
    end

    context "when a provider contains the value" do
      it "returns the value" do
        expect(described_class.load_value("VALUE", default: "VALUE")).to eq("VALUE")
      end
    end
  end

  describe "self.default_providers" do
    context "when in a rails app" do
      before do
        allow(ContainerConfig).to receive(:rails_app?).and_return(true)
      end

      it "returns the default providers and rails providers" do
        providers = described_class.default_providers
        expect(providers.count).to eq(4)
        expect(providers[2]).to be_a(ContainerConfig::Provider::RailsCredential)
      end
    end

    context "when not in a rails app" do
      before do
        allow(ContainerConfig).to receive(:rails_app?).and_return(false)
      end

      it "returns the default providers" do
        providers = described_class.default_providers
        expect(providers.count).to eq(3)
      end
    end
  end

  describe "self.rails_providers" do
    it "returns the rails providers" do
      providers = described_class.rails_providers
      expect(providers.first).to be_a(ContainerConfig::Provider::RailsCredential)
    end
  end
end
