# frozen_string_literal: true

require "container_config/coercer/base"

module ContainerConfig
  module Coercer
    # Symbol type coercer
    class Symbol < Base
      # @see ContainerConfig::Coercer::Base#name
      def name
        "Symbol"
      end

      # @see ContainerConfig::Coercer::Base#type
      def type
        :symbol
      end

      #
      # Coerces the given value into a symbol
      #
      # @param [Object] value given value
      #
      # @return [Symbol] coerced value
      #
      def coerce(value)
        return if value.nil?

        value.to_s.to_sym
      end
    end
  end
end
