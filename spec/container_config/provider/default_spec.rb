# frozen_string_literal: true

RSpec.describe ContainerConfig::Provider::Default do
  subject { described_class.new }

  describe "#name" do
    it "returns its name" do
      expect(subject.name).to eq("Default Value")
    end
  end

  describe "#load" do
    it "returns the default value" do
      expect(subject.load("anything")).to eq(nil)
      expect(subject.load("anything", default: "The default")).to eq("The default")
    end
  end
end
