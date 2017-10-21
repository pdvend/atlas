# frozen_string_literal: true

module Atlas
  module API
    module Renderer
      class BaseRenderer
        attr_reader :service_response

        def initialize(service_response)
          @service_response = service_response
        end

        def headers
          data = service_response.data
          return {} unless data.is_a?(Atlas::Service::Mechanism::Pagination::QueryResult)
          { 'Total' => data.total.to_s, 'Per-Page' => data.per_page.to_s }
        end

        def body
          error_from(service_response).to_json unless service_response.success?
        end

        protected

        def body_data
          return error_from(service_response) unless service_response.success?
          service_data = service_response.data
          service_data.is_a?(Atlas::Service::Mechanism::Pagination::QueryResult) ? service_data.results : service_data
        end

        private

        def error_from(service_response)
          { code: service_response.code, message: service_response.message, errors: service_response.data }
        end
      end
    end
  end
end
