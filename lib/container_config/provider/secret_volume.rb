# frozen_string_literal: true

require "container_config/provider/base"

module ContainerConfig
  module Provider
    # Secret volume mount config value provider
    class SecretVolume < Base
      # Default secret volume mount path used when globbing secret files
      DEFAULT_SECRET_PATH = "/etc/*-secrets"

      attr_accessor :default_directory, :directory

      # @see ContainerConfig::Provider::Base#name
      def name
        "Secret Volume"
      end

      #
      # Initializes a new ContainerConfig::Provider::SecretVolume
      #
      def initialize
        super
        @default_directory = DEFAULT_SECRET_PATH
        @directory = nil
      end

      #
      # Loads a secret volume mount configuration setting
      #
      # @param [String] key Configuration key to load
      # @param [Array] dig_keys Variable keys to use to load from providers that accept a dig structure
      #                         defaults to the lowercase key split by underscores
      #                         "MY_PASSWORD" => ["my", "password"]
      # @param [Hash] options Options Hash
      # @option options [String]  :secret_mount_directory directory where secret files are mounted
      #
      # @return [Object] configuration setting value
      #
      def load(key, *dig_keys, **options)
        super
        secret_file = Dir.glob(File.join(secret_mount_directory(**options), "**", key)).first
        return if secret_file.nil? || !File.exist?(secret_file)

        File.read(secret_file)
      end

      private

      def secret_mount_directory(options)
        options[:secret_mount_directory] ||
          directory ||
          ENV["SECRET_MOUNT_DIRECTORY"] ||
          default_directory
      end
    end
  end
end
