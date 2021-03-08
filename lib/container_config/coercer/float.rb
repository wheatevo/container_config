# frozen_string_literal: true

require "container_config/coercer/base"

module ContainerConfig
  module Coercer
    # Float type coercer
    class Float < Base
      # @see ContainerConfig::Coercer::Base#name
      def name
        "Float"
      end

      # @see ContainerConfig::Coercer::Base#type
      def type
        :float
      end

      #
      # Coerces the given value into a float
      #
      # @param [Object] value given value
      #
      # @return [Float] coerced value
      #
      def coerce(value)
        return 0.0 unless value.respond_to?(:to_f)

        value.to_f
      end
    end
  end
end
