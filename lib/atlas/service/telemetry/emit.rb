# frozen_string_literal: true

module Atlas
  module Service
    module Telemetry
      class Emit
        include Atlas::Util::I18nScope

        def initialize
          # TODO: Receive adapter by configuration
          @adapter = if Atlas::Util::Environment.production?
                       Adapter::KafkaAdapter.new
                     else
                       Adapter::StdoutAdapter.new
                     end
        end

        def execute(context, event)
          type = event.try(:[], :type)
          data = event.try(:[], :data)

          unless valid_params(context, type, data)
            message = I18n.t(:invalid_parameters, scope: i18n_scope)
            return ServiceResponse.new(message: message, data: {}, code: Enum::ErrorCodes::PARAMETER_ERROR)
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
