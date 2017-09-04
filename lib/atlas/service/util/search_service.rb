module Atlas
  module Service
    module Util
      module SearchService
        I18N_SCOPE = %i[atlas service util search_service].freeze

        protected

        def format(repository, params)
          repository_method = repository_method_by_params(params[:query_params])
          response = Atlas::Service::Mechanism::ServiceResponseFormatter.new.format(repository, repository_method, params)
          response.success ? result_from_success(response) : result_from_failure(response)
        end

        def repository_method_by_params(query_params)
          return :transform if query_params.try(:[], :transform).present?
          :find_paginated
        end

        def result_from_success(response)
          Atlas::Service::ServiceResponse.new(data: response.data, code: Enum::ErrorCodes::NONE)
        end

        def result_from_failure(_response)
          message = I18n.t(:repository_failure, scope: I18N_SCOPE)
          Atlas::Service::ServiceResponse.new(message: message, data: {}, code: Enum::ErrorCodes::INTERNAL)
        end
      end
    end
  end
end
