# frozen_string_literal: true

module Atlas
  module Repository
    class RedisRepository
      attr_reader :redis_instance

      def initialize(redis_instance)
        @redis_instance = redis_instance
      end

      def get(key)
        redis_instance.get(key)
      end

      def set(key, value, expiration:)
        response = redis_instance.set(key, value, ex: expiration)
        response == 'OK' ? value : response
      end

      def cache(key, expiration:, &block)
        value = redis_instance.get(key)
        return value unless value.nil?
        block.call.tap do |block|
          redis_instance.set(key, block, ex: expiration, nx: true)
        end
      end

      def close
        redis_instance.close
      end
    end
  end
end
