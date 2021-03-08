# frozen_string_literal: true

RSpec.describe ContainerConfig::Coercer::Base do
  subject { described_class.new }

  describe "#name" do
    it "raises an exception" do
      expect { subject.name }.to raise_error(ContainerConfig::MissingOverride)
    end
  end

  describe "#type" do
    it "raises an exception" do
      expect { subject.type }.to raise_error(ContainerConfig::MissingOverride)
    end
  end

  describe "#coerce" do
    it "raises an exception" do
      expect { subject.coerce("MY_VAL") }.to raise_error(ContainerConfig::MissingOverride)
    end
  end
end
