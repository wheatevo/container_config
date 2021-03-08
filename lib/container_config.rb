# frozen_string_literal: true

require_relative "container_config/version"

module ContainerConfig
  NAME = "ContainerConfig"
  #
  # Loads a configuration setting from environment variables, mounted secrets, or the application credentials
  #
  # @param [String] key Environment key to load
  # @param [Array] cred_keys Variable keys to use to load from the credential store
  #                          defaults to the lowercase key split by underscores
  #                          "MY_PASSWORD" => ["my", "password"]
  # @param [Hash] options Options Hash
  # @option options [Boolean] :raise whether to raise an exception if the setting cannot be found
  # @option options [String]  :default default value if the configuration setting cannot be found
  # @option options [String]  :secret_mount_directory directory where secret files are mounted
  # @option options [Boolean] :coerce_nil where to coerce nil values (defaults to true)
  # @option options [Symbol]  :type type to use such as :boolean, :integer, :string, :symbol,
  #                                 :ssl_verify_mode, :ssl_certificate, or :ssl_key
  # @option options [Array]   :enum valid values for the configuration parameter, raises an exception
  #                                 if the value is not in the enum
  #
  # @return [Object] configuration setting value
  #
  def self.load(key, *cred_keys, **options)
    logger.debug { "Loading configuration value for #{key}" }
    options[:raise] ||= false
    cred_keys = default_cred_keys(key) if cred_keys.empty?
    config_value = ENV[key]
    config_value ||= secret_mount_value(key, options)
    config_value ||= Rails.application.credentials.config.dig(*cred_keys.map(&:to_sym))
    config_value ||= options[:default] if options.key?(:default)

    # Handle missing values
    if config_value.present?
      Rails.logger&.debug { "Configuration value for #{key} loaded" }
    else
      Rails.logger&.info { "Could not find value for #{key} in ENV, secret mounts, or Rails credentials" }
      raise "Could not find value for #{key} in ENV or #{cred_keys} in Rails credentials!" if options[:raise]
    end

    if options[:coerce_nil] != false || !config_value.nil?
      config_value = coerce_value_type(config_value, options[:type])
    end

    if options[:enum] && !options[:enum].include?(config_value)
      raise "Config value #{config_value.inspect} is not a valid value. Valid values: #{options[:enum].join(', ')}"
    end

    config_value
  end

  class Error < StandardError; end
end
