# frozen_string_literal: true

RSpec.describe ContainerConfig::Coercer::Boolean do
  subject { described_class.new }

  describe "#name" do
    it "returns its name" do
      expect(subject.name).to eq("Boolean")
    end
  end

  describe "#type" do
    it "returns its symbolized type" do
      expect(subject.type).to eq(:boolean)
    end
  end

  describe "#coerce" do
    it "coerces the value" do
      expect(subject.coerce(true)).to eq(true)
      expect(subject.coerce("true")).to eq(true)
      expect(subject.coerce("TRUE")).to eq(true)
      expect(subject.coerce("1")).to eq(true)
      expect(subject.coerce(1)).to eq(true)
      expect(subject.coerce(false)).to eq(false)
      expect(subject.coerce("false")).to eq(false)
      expect(subject.coerce("FALSE")).to eq(false)
      expect(subject.coerce("")).to eq(false)
      expect(subject.coerce(nil)).to eq(false)
      expect(subject.coerce("0")).to eq(false)
      expect(subject.coerce(0)).to eq(false)
    end
  end
end
