# frozen_string_literal: true

RSpec.describe ContainerConfig::Coercer::String do
  subject { described_class.new }

  describe "#name" do
    it "returns its name" do
      expect(subject.name).to eq("String")
    end
  end

  describe "#type" do
    it "returns its symbolized type" do
      expect(subject.type).to eq(:string)
    end
  end

  describe "#coerce" do
    it "coerces the value" do
      expect(subject.coerce(true)).to eq("true")
      expect(subject.coerce(false)).to eq("false")
      expect(subject.coerce("true")).to eq("true")
      expect(subject.coerce("0.5")).to eq("0.5")
      expect(subject.coerce(0)).to eq("0")
      expect(subject.coerce(50_000)).to eq("50000")
      expect(subject.coerce("-200")).to eq("-200")
    end
  end
end
