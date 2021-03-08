# frozen_string_literal: true

require "container_config"
require "container_config/provider/base"
require "container_config/provider/default"
require "container_config/provider/env"
require "container_config/provider/rails_credential"
require "container_config/provider/secret_volume"

module ContainerConfig
  # Contains classes and methods for config value providers
  module Provider
    #
    # Loads a value from the config value providers
    #
    # @param [String] key Configuration key to load
    # @param [Array] dig_keys Variable keys to use to load from providers that accept a dig structure
    #                         defaults to the lowercase key split by underscores
    #                         "MY_PASSWORD" => ["my", "password"]
    # @param [Hash] options Options Hash
    # @option options [String]  :default default value if the configuration setting cannot be found
    # @option options [String]  :secret_mount_directory directory where secret files are mounted
    # @option options [Symbol]  :type type to use such as :boolean, :integer, :string, :symbol,
    #                                 :ssl_verify_mode, :ssl_certificate, or :ssl_key
    #
    # @return [Object] configuration setting value
    #
    def self.load_value(key, *dig_keys, **options)
      value = nil
      ContainerConfig.providers.each do |p|
        value = p.load(key, *dig_keys, **options)
        break unless value.nil?
      end

      value
    end

    #
    # Array of default providers
    #
    # @return [Array<ContainerConfig::Provider::Base>] default providers
    #
    def self.default_providers
      defaults = [
        ContainerConfig::Provider::Env.new,
        ContainerConfig::Provider::SecretVolume.new
      ]

      defaults |= rails_providers if ContainerConfig.rails_app?
      defaults << ContainerConfig::Provider::Default.new

      defaults
    end

    #
    # Array of Rails providers
    # These are only included in the default providers when this gem is included
    # as part of a rails application
    #
    # @return [Array<ContainerConfig::Provider::Base>] default providers
    #
    def self.rails_providers
      [ContainerConfig::Provider::RailsCredential.new]
    end
  end
end
