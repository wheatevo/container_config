# frozen_string_literal: true

require "container_config"

module ContainerConfig
  module Provider
    # Base config value provider
    class Base
      #
      # Returns name of the config value provider
      #
      # @return [String] provider name
      #
      def name
        raise ContainerConfig::MissingOverride, "Must override name method in derived class #{self.class}"
      end

      #
      # Loads a configuration setting from the provider
      #
      # @param [String] key Configuration key to load
      # @param [Array] _dig_keys Variable keys to use to load from providers that accept a dig structure
      #                         defaults to the lowercase key split by underscores
      #                         "MY_PASSWORD" => ["my", "password"]
      # @param [Hash] options Options Hash
      # @option options [String]  :default default value if the configuration setting cannot be found
      # @option options [String]  :secret_mount_directory directory where secret files are mounted
      #
      # @return [Object] configuration setting value
      #
      def load(key, *_dig_keys, **options)
        ContainerConfig.logger.debug do
          "Loading configuration value for #{key} with options #{options} from #{self.class}"
        end
        nil
      end
    end
  end
end
