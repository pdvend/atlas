# frozen_string_literal: true

module Atlas
  module Job
    module Backend
      class Kafka
        class Consumer
          def initialize(consumer)
            @consumer = consumer
          end

          def listen(topic)
            @consumer.subscribe(topic)
          end

          def consume(&block)
            # Stop the consumer when the SIGTERM signal is sent to the process.
            # It's better to shut down gracefully than to kill the process.
            trap('TERM') { @consumer.stop }
            @consumer.each_message(automatically_mark_as_processed: false, &consume_message(block))
          end

          def mark_message_as_processed(message)
            @consumer.mark_message_as_processed(message.vendor_message)
          end

          private

          def consume_message(block)
            lambda do |kafka_message|
              message = job_message_from_kafka_message(kafka_message)
              block.call(message) if message
            end
          end

          def job_message_from_kafka_message(kafka_message)
            parsed_object = JSON.parse(kafka_message.value).try(:deep_symbolize_keys) || {}
            job_message_from_parsed_kafka_message(parsed_object)
            job_message if job_message.valid?
          rescue StandardError
            nil
          end

          def job_message_from_parsed_kafka_message(parsed_object)
            job_params = relevant_keys_from_kafka_message(parsed_object)
            JobMessage.new(**job_params, topic: kafka_message.topic, vendor_message: kafka_message)
          end

          def relevant_keys_from_kafka_message(parsed_object)
            %i[payload timestamp retries].reduce({}) do |params, key|
              { **params, key => parsed_object[key] }
            end
          end
        end
      end
    end
  end
end
