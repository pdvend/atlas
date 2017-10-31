# frozen_string_literal: true

module Atlas
  module Job
    module Backend
      class Noop
        def listen(_topic); end

        def consume; end

        def mark_message_as_processed(_message); end

        def produce_batch(_topic, _batch); end

        def produce(_topic, _message); end
      end
    end
  end
end
