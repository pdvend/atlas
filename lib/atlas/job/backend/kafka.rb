# frozen_string_literal: true

require_relative 'kafka/consumer'
require_relative 'kafka/producer'

module Atlas
  module Job
    module Backend
      class Kafka
        extend Forwardable

        def initialize(kafka, group_id)
          @consumer = Consumer.new(kafka.consumer(group_id: group_id))
          @producer = Producer.new(kafka.producer)
        end

        def_delegator :@consumer, :listen, :listen
        def_delegator :@consumer, :consume, :consume
        def_delegator :@consumer, :mark_message_as_processed, :mark_message_as_processed
        def_delegator :@producer, :produce_batch, :produce_batch
        def_delegator :@producer, :produce, :produce
      end
    end
  end
end
