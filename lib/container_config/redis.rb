# frozen_string_literal: true

require "container_config"

module ContainerConfig
  # Redis configuration module
  module Redis
    #
    # Loads Redis configuration settings from environment variables, mounted secrets, or the application credentials
    #
    # @param [String] key base key for the Redis config ("QUEUE", "CACHE", etc.)
    # @param [Hash] options Options Hash
    # @option options [Boolean] :required whether to raise an exception if the settings cannot be found
    # @option options [String] :secret_mount_directory directory where secret files are mounted
    #
    # @return [Hash] Redis configuration hash with :url, :password, and :sentinels keys
    #                See https://github.com/redis/redis-rb for more information
    #
    def self.load(key, **options)
      host = ContainerConfig.load("#{key}_HOST", **options, default: "localhost")
      port = ContainerConfig.load("#{key}_PORT", **options, default: "6379")

      url = ContainerConfig.load("#{key}_URL", **options, default: "redis://#{host}:#{port}")
      sentinels = sentinel_info(key, **options)
      password = ContainerConfig.load("#{key}_PASSWORD", **options)

      # Ensure we never pass an empty string to Redis since it will be passed to the Redis AUTH
      # command as-is and will cause an exception
      password = nil if password.to_s.strip.empty?

      redis_config = { url: url, password: password }
      redis_config[:sentinels] = sentinels unless sentinels.empty?

      # Add SSL configuration
      redis_config[:ssl] = ContainerConfig.load("#{key}_SSL", **options, default: false)
      redis_config[:ssl_params] = ssl_params(key, **options)

      redis_config
    end

    class << self
      private

      #
      # Load Redis Sentinel configuration settings
      #
      # @param [String] key base key for the Redis Sentinel config
      # @param [Hash] options Options Hash
      # @option options [Boolean] :required whether to raise an exception if the settings cannot be found
      # @option options [String] :secret_mount_directory directory where secret files are mounted
      #
      # @return [Array] Redis sentinel configuration hashes, may be empty if no sentinel config exists
      #                 Each hash will have :host, :port, and :password keys
      #
      def sentinel_info(key, **options)
        sentinel_hosts = ContainerConfig.load("#{key}_SENTINELS", **options, default: [])
        sentinel_hosts = sentinel_hosts.split(",").map(&:strip) if sentinel_hosts.is_a?(String)

        sentinel_port = ContainerConfig.load("#{key}_SENTINEL_PORT", **options, default: "26379")
        sentinel_password = ContainerConfig.load("#{key}_SENTINEL_PASSWORD", **options)

        # Ensure we never pass an empty string to Redis since it will be passed to the Redis sentinel AUTH
        # command as-is and will cause an exception
        sentinel_password = nil if sentinel_password.to_s.strip.empty?

        ssl_params = ssl_params("#{key}_SENTINEL", **options)

        sentinel_hosts.map { |h| { host: h, port: sentinel_port, password: sentinel_password, ssl_params: ssl_params } }
      end

      #
      # Load Redis SSL parameters
      #
      # @param [String] key base key for the Redis/Redis Sentinel config
      # @param [Hash] options Options Hash
      # @option options [Boolean] :required whether to raise an exception if the settings cannot be found
      # @option options [String] :secret_mount_directory directory where secret files are mounted
      #
      # @return [Hash] SSL parameter hash (see OpenSSL::SSL::SSLContext documentation)
      #
      def ssl_params(key, **options)
        ssl_params = {
          ca_file: ContainerConfig.load("#{key}_SSL_CA_FILE", **options),
          ca_path: ContainerConfig.load("#{key}_SSL_CA_PATH", **options),
          cert: ContainerConfig.load("#{key}_SSL_CERT", **options, type: :ssl_certificate),
          key: ContainerConfig.load("#{key}_SSL_KEY", **options, type: :ssl_key),
          verify_mode: ContainerConfig.load("#{key}_SSL_VERIFY_MODE", **options, type: :ssl_verify_mode)
        }

        # Reject all nil key values
        ssl_params.compact
      end
    end
  end
end
