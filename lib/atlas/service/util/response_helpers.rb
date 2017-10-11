# frozen_string_literal: true

module Atlas
  module Service
    module Util
      module ResponseHelpers
        def self.included(base)
          base.class_eval do
            include Atlas::Util::I18nScope
          end
        end

        protected

        def successful_response(data)
          Atlas::Service::ServiceResponse.new(data: data, code: Enum::ErrorCodes::NONE)
        end

        def invalid_entity_response(entity)
          failure_response(
            key: :invalid_entity,
            code: Enum::ErrorCodes::VALIDATION,
            errors: entity.errors
          )
        end

        # :reek:LongParameterList
        def failure_response(key:, code: Enum::ErrorCodes::INTERNAL, errors: {}, message: I18n.t(key, scope:i18n_scope))
          Atlas::Service::ServiceResponse.new(message: message, data: errors, code: code)
        end
      end
    end
  end
end
