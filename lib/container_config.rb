# frozen_string_literal: true

require "container_config/version"
require "container_config/logger"
require "container_config/provider"
require "container_config/coercer"
require "container_config/redis"

# Contains methods for loading and parsing container configuration
module ContainerConfig
  #
  # Loads a configuration setting from environment variables, mounted secrets, or the application credentials
  #
  # @param [String] key Configuration key to load
  # @param [Array] dig_keys Variable keys to use to load from providers that accept a dig structure
  #                         defaults to the lowercase key split by underscores
  #                         "MY_PASSWORD" => ["my", "password"]
  # @param [Hash] options Options Hash
  # @option options [Boolean] :required whether to raise an exception if the setting cannot be found
  # @option options [String]  :default default value if the configuration setting cannot be found
  # @option options [String]  :secret_mount_directory directory where secret files are mounted
  # @option options [Boolean] :coerce_nil where to coerce nil values (defaults to true)
  # @option options [Boolean] :cache whether to cache the retrieved value and to return that value in future calls
  #                                  future calls must also specify cache: true to prevent the value from being re-read
  # @option options [Symbol]  :type type to use such as :boolean, :integer, :string, :symbol,
  #                                 :ssl_verify_mode, :ssl_certificate, or :ssl_key
  # @option options [Array]   :enum valid values for the configuration parameter, raises an exception
  #                                 if the value is not in the enum
  #
  # @return [Object] configuration setting value
  #
  def self.load(key, *dig_keys, **options)
    logger.debug { "Loading configuration value for #{key}" }
    options[:required] ||= options[:raise] || false
    dig_keys = key.downcase.split("_") if dig_keys.empty?

    return cache[key] if options[:cache] && cache.key?(key)

    config_value = ContainerConfig::Provider.load_value(key, *dig_keys, **options)
    handle_empty_value(config_value, key, **options)
    config_value = ContainerConfig::Coercer.coerce_value(config_value, options[:type], **options)
    handle_enum(config_value, **options)

    cache[key] = config_value if options[:cache]

    config_value
  end

  #
  # Clears all entries from the configuration cache
  #
  def self.clear_cache
    @cache = {}
  end

  #
  # Gets the configuration cache
  #
  # @return [Hash] configuration cache
  #
  def self.cache
    @cache ||= {}
  end

  #
  # Gets the list of configuration value coercers
  #
  # @return [Array<ContainerConfig::Coercer::Base>] current value coercers
  #
  def self.coercers
    @coercers ||= ContainerConfig::Coercer.default_coercers
  end

  #
  # Sets the list of configuration value coercers
  #
  # @param [Array<ContainerConfig::Coercer::Base>] coercers new value coercers
  #
  def self.coercers=(coercers)
    @coercers = coercers
  end

  #
  # Gets the list of configuration value providers
  #
  # @return [Array<ContainerConfig::Provider::Base>] current value providers
  #
  def self.providers
    @providers ||= ContainerConfig::Provider.default_providers
  end

  #
  # Sets the list of configuration value providers
  #
  # @param [Array<ContainerConfig::Provider::Base>] providers new value providers
  #
  def self.providers=(providers)
    @providers = providers
  end

  #
  # Gets the container config logger
  #
  # @return [ContainerConfig::Logger] current logger
  #
  def self.logger
    @logger ||= ContainerConfig::Logger.new($stdout, level: Logger::INFO)
  end

  #
  # Sets the container config logger
  #
  # @param [::Logger] logger logger to set
  #
  def self.logger=(logger)
    if logger.nil?
      self.logger.level = Logger::FATAL
      return self.logger
    end
    @logger = logger
  end

  #
  # Gets the container config log formatter
  #
  # @return [::Logger::Formatter] current log formatter
  #
  def self.log_formatter
    @log_formatter ||= logger.formatter
  end

  #
  # Sets the container config log formatter
  #
  # @param [::Logger::Formatter] log_formatter new log formatter
  #
  def self.log_formatter=(log_formatter)
    @log_formatter = log_formatter
    logger.formatter = log_formatter
  end

  #
  # Whether this is in the context of a Rails application
  #
  # @return [Boolean] true if in a Rails application, false otherwise
  #
  def self.rails_app?
    defined?(::Rails) && ::Rails.respond_to?(:application)
  end

  class << self
    private

    def handle_empty_value(config_value, key, **options)
      if config_value.nil? || config_value.to_s.empty?
        provider_list = providers.map(&:name).join(", ")
        logger.debug { "Could not find value for #{key} in providers: #{provider_list}" }
        raise MissingRequiredValue, "Could not find value for #{key} in providers: #{provider_list}!" if options[:required]
      else
        logger.debug { "Configuration value for #{key} loaded" }
      end
    end

    def handle_enum(config_value, **options)
      return if !options[:enum] || options[:enum].include?(config_value)

      valid_values = options[:enum].join(", ")
      raise InvalidEnumValue, "Config value #{config_value.inspect} is invalid. Valid values: #{valid_values}"
    end
  end

  # General ContainerConfig error
  class Error < StandardError; end

  # Error raised when a required value is missing when loading a configuration value
  class MissingRequiredValue < Error; end

  # Error raised when a derived class is missing an override method
  class MissingOverride < Error; end

  # Error raised when a configuration value is not within the provided enum
  class InvalidEnumValue < Error; end
end

require "container_config/rails" if ContainerConfig.rails_app?
