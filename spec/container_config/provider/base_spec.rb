# frozen_string_literal: true

RSpec.describe ContainerConfig::Provider::Base do
  subject { described_class.new }

  describe "#name" do
    it "returns its name" do
      expect { subject.name }.to raise_error(ContainerConfig::MissingOverride)
    end
  end

  describe "#load" do
    it "returns nil" do
      expect(subject.load("anything")).to eq(nil)
    end
  end
end
