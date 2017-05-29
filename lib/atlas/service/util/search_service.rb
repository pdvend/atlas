module Atlas
  module Service
    module Util
      module SearchService
        def self.included(base)
          base.class_eval do
            include Atlas::Util::I18nScope
          end
        end

        protected

        def format(params, &block)
          response = Atlas::Service::Mechanism::ServiceResponseFormatter.new.format(params, &block)
          response.success ? result_from_success(response) : result_from_failure(response)
        end

        def result_from_success(response)
          Atlas::Service::ServiceResponse.new(data: response.data, code: Enum::ErrorCodes::NONE)
        end

        def result_from_failure(_response)
          message = I18n.t(:repository_failure, scope: i18n_scope)
          Atlas::Service::ServiceResponse.new(message: message, data: {}, code: Enum::ErrorCodes::INTERNAL)
        end
      end
    end
  end
end
