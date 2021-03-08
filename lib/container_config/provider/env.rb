# frozen_string_literal: true

require "container_config/provider/base"

module ContainerConfig
  module Provider
    # Environment variable config value provider
    class Env < Base
      # @see ContainerConfig::Provider::Base#name
      def name
        "Environment Variable"
      end

      #
      # Loads an environment value configuration setting
      #
      # @param [String] key Configuration key to load
      # @param [Array] dig_keys Variable keys to use to load from providers that accept a dig structure
      # @param [Hash] options Options Hash
      #
      # @return [Object] configuration setting value
      #
      def load(key, *dig_keys, **options)
        super
        ENV[key]
      end
    end
  end
end
