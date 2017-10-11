# frozen_string_literal: true

module Atlas
  module Service
    module Telemetry
      module Adapter
        class FirehoseAdapter
          include Atlas::Util::I18nScope

          # TODO: Receive this constants by parameter
          REGION_NAME = ENV['AWS_FIREHOSE_REGION_NAME']
          TELEMETRY_STREAM_PREFIX = ENV['AWS_FIREHOSE_TELEMETRY_STREAM_PREFIX']

          def initialize
            @firehose = Aws::Firehose::Client.new(region: REGION_NAME)
          end

          def log(type, data)
            @firehose.put_record(
              delivery_stream_name: "#{TELEMETRY_STREAM_PREFIX}#{type}",
              record: { data: data.to_json }
            )

            ServiceResponse.new(data: nil, code: Enum::ErrorCodes::NONE)
          rescue Aws::Firehose::Errors::ResourceNotFoundException
            message = I18n.t(:service_unavailable, scope: i18n_scope)
            ServiceResponse.new(message: message, data: {}, code: Enum::ErrorCodes::INTERNAL)
          end
        end
      end
    end
  end
end
