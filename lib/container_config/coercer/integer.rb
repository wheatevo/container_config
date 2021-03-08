# frozen_string_literal: true

require "container_config/coercer/base"

module ContainerConfig
  module Coercer
    # Integer type coercer
    class Integer < Base
      # @see ContainerConfig::Coercer::Base#name
      def name
        "Integer"
      end

      # @see ContainerConfig::Coercer::Base#type
      def type
        :integer
      end

      #
      # Coerces the given value into an integer
      #
      # @param [Object] value given value
      #
      # @return [Integer] coerced value
      #
      def coerce(value)
        return 0 unless value.respond_to?(:to_i)

        value.to_i
      end
    end
  end
end
