# frozen_string_literal: true

module Adapter
  require_relative 'adapter/firehose_adapter'
  require_relative 'adapter/kafka_adapter'
  require_relative 'adapter/noop_adapter'
  require_relative 'adapter/stdout_adapter'
end
