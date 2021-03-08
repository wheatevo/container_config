# frozen_string_literal: true

require "container_config/coercer/base"

module ContainerConfig
  module Coercer
    # String type coercer
    class String < Base
      # @see ContainerConfig::Coercer::Base#name
      def name
        "String"
      end

      # @see ContainerConfig::Coercer::Base#type
      def type
        :string
      end

      #
      # Coerces the given value into a string
      #
      # @param [Object] value given value
      #
      # @return [String] coerced value
      #
      def coerce(value)
        value.to_s
      end
    end
  end
end
