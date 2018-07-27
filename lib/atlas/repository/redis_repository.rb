# frozen_string_literal: true

module Atlas
  module Repository
    class RedisRepository
      attr_reader :redis_instance

      def initialize(redis_instance)
        @redis_instance = redis_instance
      end

      def cache(key, expiration:, &block)
        value = redis_instance.get(key)
        return value unless value.nil?
        block_call = block.call
        redis_instance.set(key, block_call, ex: expiration, nx: true)
        block_call
      end
    end
  end
end
