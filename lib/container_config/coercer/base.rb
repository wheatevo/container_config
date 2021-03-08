# frozen_string_literal: true

module ContainerConfig
  module Coercer
    # Base type coercer
    class Base
      #
      # Returns name of the coercer
      #
      # @return [String] coercer name
      #
      def name
        raise ContainerConfig::MissingOverride, "Must override name method in derived class #{self.class}"
      end

      #
      # Returns the type of the coercer
      # This is used by the ContainerConfig::Coercer.coerce_value method to determine
      # whether this coercer should be used for a given type
      #
      # @return [Symbol] coercer type
      #
      def type
        raise ContainerConfig::MissingOverride, "Must override type method in derived class #{self.class}"
      end

      #
      # Coerces the given value into the coercer type
      #
      # @param [Object] _value given value
      #
      # @return [Object] coerced value
      #
      def coerce(_value)
        raise ContainerConfig::MissingOverride, "Must override coerce method in derived class #{self.class}"
      end
    end
  end
end
