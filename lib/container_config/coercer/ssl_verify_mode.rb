# frozen_string_literal: true

require "container_config"
require "container_config/coercer/base"
require "openssl"

module ContainerConfig
  module Coercer
    # SSL verification mode type coercer
    class SslVerifyMode < Base
      # Array of valid SSL verification modes
      VALID_MODES = OpenSSL::SSL.constants.select { |c| c.to_s.start_with?("VERIFY") }.map(&:to_s)

      # @see ContainerConfig::Coercer::Base#name
      def name
        "SSL Verification Mode"
      end

      # @see ContainerConfig::Coercer::Base#type
      def type
        :ssl_verify_mode
      end

      #
      # Coerces the given value into an SSL verification mode
      #
      # @param [Object] value SSL verification mode string ("VERIFY_NONE", "VERIFY_PEER", etc.)
      #
      # @return [Integer] coerced value
      #
      def coerce(value)
        value = value.to_s
        return Object.const_get("OpenSSL::SSL::#{value}") if VALID_MODES.include?(value)

        ContainerConfig.logger.warn do
          "Could not convert #{value.inspect} into a valid OpenSSL verification mode.\nValid modes: #{VALID_MODES.join(", ")}"
        end
        nil
      end
    end
  end
end
