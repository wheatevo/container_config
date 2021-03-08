# frozen_string_literal: true

RSpec.describe ContainerConfig::Coercer::Float do
  subject { described_class.new }

  describe "#name" do
    it "returns its name" do
      expect(subject.name).to eq("Float")
    end
  end

  describe "#type" do
    it "returns its symbolized type" do
      expect(subject.type).to eq(:float)
    end
  end

  describe "#coerce" do
    it "coerces the value" do
      expect(subject.coerce(true)).to eq(0.0)
      expect(subject.coerce(false)).to eq(0.0)
      expect(subject.coerce("true")).to eq(0.0)
      expect(subject.coerce("0.5")).to eq(0.5)
      expect(subject.coerce(0)).to eq(0.0)
      expect(subject.coerce(50_000)).to eq(50_000.0)
      expect(subject.coerce("-200")).to eq(-200.0)
    end
  end
end
