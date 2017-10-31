# frozen_string_literal: true

module Atlas
  module Service
    module Telemetry
      module Adapter
        class FirehoseAdapter
          include Atlas::Util::I18nScope

          def initialize(stream_prefix = '', **options)
            @stream_prefix = stream_prefix
            @firehose = Aws::Firehose::Client.new(**options)
          end

          def log(type, data)
            @firehose.put_record(
              delivery_stream_name: "#{@stream_prefix}#{type}",
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
