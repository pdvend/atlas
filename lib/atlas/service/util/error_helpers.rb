module Atlas
  module Service
    module Util
      module ErrorHelpers
        def self.included(base)
          base.class_eval do
            include Atlas::Util::I18nScope
          end
        end

        protected

        def invalid_entity_response(entity, message = nil)
          failure_response(
            key: :invalid_entity,
            code: Enum::ErrorCodes::VALIDATION,
            errors: entity.errors
          )
        end

        def failure_response(key: nil, code: Enum::ErrorCodes::INTERNAL, errors: {})
          Atlas::Service::ServiceResponse.new(
            message: I18n.t(key, scope: i18n_scope),
            data: entity.errors,
            code: Enum::ErrorCodes::VALIDATION
          )
        end
      end
    end
  end
end
