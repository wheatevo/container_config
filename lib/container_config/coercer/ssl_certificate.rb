# frozen_string_literal: true

require "container_config"
require "container_config/coercer/base"
require "openssl"

module ContainerConfig
  module Coercer
    # SSL certificate type coercer
    class SslCertificate < Base
      # @see ContainerConfig::Coercer::Base#name
      def name
        "SSL Certificate"
      end

      # @see ContainerConfig::Coercer::Base#type
      def type
        :ssl_certificate
      end

      #
      # Coerces the given value into an SSL certificate
      #
      # @param [Object] value SSL certificate path
      #
      # @return [OpenSSL::X509::Certificate] coerced value
      #
      def coerce(value)
        return if value.nil?

        return value if value.is_a?(OpenSSL::X509::Certificate)

        cert_path = value.to_s

        unless File.exist?(cert_path)
          ContainerConfig.logger.warn { "Could not find SSL certificate at #{cert_path}" }
          return nil
        end

        OpenSSL::X509::Certificate.new(File.read(cert_path))
      rescue OpenSSL::X509::CertificateError => e
        ContainerConfig.logger.warn { "Could not parse SSL certificate #{cert_path} successfully: #{e}" }
        nil
      end
    end
  end
end
