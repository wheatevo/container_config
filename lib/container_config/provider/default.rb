# frozen_string_literal: true

require "container_config/provider/base"

module ContainerConfig
  module Provider
    # Default config value provider (handles :default option)
    class Default < Base
      # @see ContainerConfig::Provider::Base#name
      def name
        "Default Value"
      end

      #
      # Loads a default configuration setting based on the value of options[:default]
      #
      # @param [String] key Configuration key to load
      # @param [Array] dig_keys Variable keys to use to load from providers that accept a dig structure
      # @param [Hash] options Options Hash
      # @option options [String]  :default default value if the configuration setting cannot be found
      #
      # @return [Object] configuration setting value
      #
      def load(key, *dig_keys, **options)
        super
        options[:default]
      end
    end
  end
end
