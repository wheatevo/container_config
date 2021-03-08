# frozen_string_literal: true

require "container_config/coercer/base"

module ContainerConfig
  module Coercer
    # Boolean type coercer
    class Boolean < Base
      # @see ContainerConfig::Coercer::Base#name
      def name
        "Boolean"
      end

      # @see ContainerConfig::Coercer::Base#type
      def type
        :boolean
      end

      #
      # Coerces the given value into a boolean
      #
      # @param [Object] value given value
      #
      # @return [Boolean] coerced value
      #
      def coerce(value)
        # If a digit is passed, check if it is non-zero and return true for non-zero values
        return value.to_i != 0 if value.respond_to?(:to_i) && value.to_i.to_s == value.to_s

        value.to_s.casecmp?("true")
      end
    end
  end
end
