# frozen_string_literal: true

require "container_config/provider/base"

module ContainerConfig
  module Provider
    # Rails credential config value provider
    class RailsCredential < Base
      # @see ContainerConfig::Provider::Base#name
      def name
        "Rails Credential"
      end

      #
      # Loads a Rails credential configuration setting
      #
      # @param [String] key Configuration key to load
      # @param [Array] dig_keys Variable keys to use to load from providers that accept a dig structure
      #                         defaults to the lowercase key split by underscores
      #                         "MY_PASSWORD" => ["my", "password"]
      # @param [Hash] options Options Hash
      #
      # @return [Object] configuration setting value
      #
      def load(key, *dig_keys, **options)
        super
        ::Rails.application.credentials.config.dig(*dig_keys.map(&:to_sym))
      end
    end
  end
end
