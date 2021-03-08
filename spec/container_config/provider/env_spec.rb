# frozen_string_literal: true

RSpec.describe ContainerConfig::Provider::Env do
  subject { described_class.new }

  describe "#name" do
    it "returns its name" do
      expect(subject.name).to eq("Environment Variable")
    end
  end

  describe "#load" do
    it "returns the environment value" do
      expect(subject.load("anything")).to eq(nil)
      stub_const("ENV", { "anything" => "from_env" })
      expect(subject.load("anything")).to eq("from_env")
    end
  end
end
