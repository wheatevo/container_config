# frozen_string_literal: true

require "container_config"

module ContainerConfig
  module Rails
    # Rails ActionMailer config module
    module Mailer
      #
      # loads Rails ActionMailer configuration settings from environment variables, mounted secrets, or the application credentials
      #
      # @param [String] key base key for the Mailer config ("MAILER")
      # @param [Hash] options Options Hash
      # @option options [Boolean] :required whether to raise an exception if the settings cannot be found
      # @option options [String] :secret_mount_directory directory where secret files are mounted
      #
      # @return [Hash] Mailer configuration hash with :perform_deliveries, :perform_caching, :raise_delivery_errors,
      #                :delivery_method, :sendmail_settings, and :smtp_settings keys
      #
      def self.load(key, **options)
        mail_config = {}

        mail_config[:perform_deliveries] = ContainerConfig.load("#{key}_PERFORM_DELIVERIES", default: ::Rails.env.production?, type: :boolean)
        mail_config[:perform_caching] = ContainerConfig.load("#{key}_PERFORM_CACHING", default: false, type: :boolean)
        mail_config[:raise_delivery_errors] = ContainerConfig.load("#{key}_RAISE_DELIVERY_ERRORS", default: false, type: :boolean)
        mail_config[:delivery_method] = ContainerConfig.load("#{key}_DELIVERY_METHOD", default: :sendmail, type: :symbol, enum: %i[smtp sendmail])
        mail_config[:sendmail_settings] = mailer_sendmail_settings(key, **options)
        mail_config[:smtp_settings] = mailer_smtp_settings(key, **options)

        mail_config.compact
      end

      class << self
        private

        #
        # load Mailer sendmail settings
        #
        # @param [String] key base key for the Mailer sendmail config
        # @param [Hash] options Options Hash
        # @option options [Boolean] :required whether to raise an exception if the settings cannot be found
        # @option options [String] :secret_mount_directory directory where secret files are mounted
        #
        # @return [Hash] Sendmail settings hash with :location and :arguments keys
        #
        def mailer_sendmail_settings(key, **options)
          {
            location: ContainerConfig.load("#{key}_SENDMAIL_LOCATION", **options),
            arguments: ContainerConfig.load("#{key}_SENDMAIL_ARGUMENTS", **options)
          }.compact
        end

        #
        # load Mailer SMTP settings
        #
        # @param [String] key base key for the Mailer SMTP config
        # @param [Hash] options Options Hash
        # @option options [Boolean] :required whether to raise an exception if the settings cannot be found
        # @option options [String] :secret_mount_directory directory where secret files are mounted
        #
        # @return [Hash] SMTP settings hash with :address, :port, :domain, :user_name, :password, :authentication,
        #                :enable_starttls_auto, :openssl_verify_mode, :ssl, and :tls keys
        #
        def mailer_smtp_settings(key, **options)
          {
            address: ContainerConfig.load("#{key}_SMTP_ADDRESS", **options),
            port: ContainerConfig.load("#{key}_SMTP_PORT", **options, default: 25, type: :integer),
            domain: ContainerConfig.load("#{key}_SMTP_DOMAIN", **options),
            user_name: ContainerConfig.load("#{key}_SMTP_USER_NAME", **options),
            password: ContainerConfig.load("#{key}_SMTP_PASSWORD", **options),
            authentication: ContainerConfig.load("#{key}_SMTP_AUTHENTICATION", **options, type: :symbol, enum: [nil, :plain, :login, :cram_md5]),
            enable_starttls_auto: ContainerConfig.load("#{key}_SMTP_ENABLE_STARTTLS_AUTO", **options, coerce_nil: false, type: :boolean),
            openssl_verify_mode: ContainerConfig.load("#{key}_SMTP_OPENSSL_VERIFY_MODE", **options, coerce_nil: false, type: :ssl_verify_mode),
            ssl: ContainerConfig.load("#{key}_SMTP_SSL", **options, coerce_nil: false, type: :boolean),
            tls: ContainerConfig.load("#{key}_SMTP_TLS", **options, coerce_nil: false, type: :boolean)
          }.compact
        end
      end
    end
  end
end
