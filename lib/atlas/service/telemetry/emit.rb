module Platform
  module Service
    module Telemetry
      class Emit
        def initialize
          # TODO: Receive adapter by configuration
          @adapter = if Platform::Util::Environment.development?
                       Adapter::StdoutAdapter.new
                     else
                       Adapter::FirehoseAdapter.new
                     end
        end

        def execute(context, event)
          type = event.try(:[], :type)
          data = event.try(:[], :data)

          unless valid_params(context, type, data)
            errors = { base: ['Invalid parameters received'] }
            return ServiceResponse.new(data: errors, code: Enum::ErrorCodes::PARAMETER_ERROR)
          end

          @adapter.log(type, data.merge(context.to_event))
        end

        private

        def valid_params(context, type, data)
          context.is_a?(Service::RequestContext) && type.is_a?(Symbol) && data.is_a?(Hash)
        end
      end
    end
  end
end
