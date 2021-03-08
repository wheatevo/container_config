# frozen_string_literal: true

require "container_config"
require "container_config/coercer/base"
require "container_config/coercer/boolean"
require "container_config/coercer/float"
require "container_config/coercer/integer"
require "container_config/coercer/string"
require "container_config/coercer/symbol"
require "container_config/coercer/ssl_verify_mode"
require "container_config/coercer/ssl_certificate"
require "container_config/coercer/ssl_key"

module ContainerConfig
  # Contains classes and methods for type coercion
  module Coercer
    #
    # Coerces a given value into a requested type
    #
    # @param [Object] value value to coerce
    # @param [Symbol] value_type requested type such as :boolean, :integer, :string, :symbol,
    #                            :ssl_verify_mode, :ssl_certificate, or :ssl_key
    # @param [Hash] options Options Hash
    # @option options [Boolean] :coerce_nil where to coerce nil values (defaults to true)
    #
    # @return [Object] coerced value
    #
    def self.coerce_value(value, value_type = nil, options = {})
      return value unless value_type

      return value if options[:coerce_nil] == false && value.nil?

      value_type = value_type.to_sym

      ContainerConfig.coercers.each do |coercer|
        return coercer.coerce(value) if coercer.type == value_type
      end

      ContainerConfig.logger.warn { "Could not find valid coercion type for #{value_type}" }
      value
    end

    #
    # Array of default coercers
    #
    # @return [Array<ContainerConfig::Coercer::Base>] default coercers
    #
    def self.default_coercers
      [
        ContainerConfig::Coercer::Boolean.new,
        ContainerConfig::Coercer::Float.new,
        ContainerConfig::Coercer::Integer.new,
        ContainerConfig::Coercer::SslCertificate.new,
        ContainerConfig::Coercer::SslKey.new,
        ContainerConfig::Coercer::SslVerifyMode.new,
        ContainerConfig::Coercer::String.new,
        ContainerConfig::Coercer::Symbol.new
      ]
    end
  end
end
