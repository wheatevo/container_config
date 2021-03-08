# frozen_string_literal: true

require "container_config"
require "container_config/coercer/base"
require "openssl"

module ContainerConfig
  module Coercer
    # SSL key type coercer
    class SslKey < Base
      # @see ContainerConfig::Coercer::Base#name
      def name
        "SSL Private Key"
      end

      # @see ContainerConfig::Coercer::Base#type
      def type
        :ssl_key
      end

      #
      # Coerces the given value into an SSL key
      #
      # @param [Object] value SSL key path
      #
      # @return [OpenSSL::PKey::RSA] coerced value
      #
      def coerce(value)
        return if value.nil?

        key_path = value.to_s

        unless File.exist?(key_path)
          ContainerConfig.logger.warn { "Could not find SSL key at #{key_path}" }
          return
        end

        OpenSSL::PKey::RSA.new(File.read(key_path))
      rescue OpenSSL::PKey::RSAError => e
        ContainerConfig.logger.warn { "Could not parse SSL key #{key_path} successfully: #{e}" }
        nil
      end
    end
  end
end
