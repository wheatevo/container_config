# frozen_string_literal: true

RSpec.describe ContainerConfig::Coercer do
  describe "self#coerce_value" do
    context "when value type is unset" do
      it "returns the uncoerced value" do
        expect(described_class.coerce_value(500)).to eq(500)
      end
    end

    context "when value type is set" do
      it "coerces the value into the given type" do
        expect(described_class.coerce_value("123", :integer)).to eq(123)
      end

      context "when coerce_nil is false and value is nil" do
        it "returns nil" do
          expect(described_class.coerce_value(nil, nil, coerce_nil: false)).to eq(nil)
        end
      end
    end

    context "when value type is invalid" do
      it "returns the uncoerced value" do
        expect(described_class.coerce_value("my value", :invalid)).to eq("my value")
      end
    end
  end

  describe "self#default_coercers" do
    it "returns a default array of coercers" do
      expect(described_class.default_coercers.count).to eq(8)
      expect(described_class.default_coercers).to all(be_a(ContainerConfig::Coercer::Base))
    end
  end
end
