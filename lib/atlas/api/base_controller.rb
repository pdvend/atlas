module Atlas
  module API
    module BaseController
      extend Dry::Configurable
      def self.included(base)
        base.class_eval do
          include Hanami::Action
          extend Atlas::API::Context::DSL
          use Rack::Deflater
        end
      end
      setting :serializers_namespace

      ERROR_CODE_TO_HTTP_STATUS = {
        Atlas::Enum::ErrorCodes::NONE => 200,
        Atlas::Enum::ErrorCodes::AUTHENTICATION_ERROR => 401,
        Atlas::Enum::ErrorCodes::PERMISSION_ERROR => 403
      }.freeze

      def render(service_response)
        data = service_response.data
        code = service_response.code
        self.body = response_body(service_response).to_json
        self.status = ERROR_CODE_TO_HTTP_STATUS[code] || 400
        headers.merge!(response_headers(data))
      end

      def render_pdf(service_response)
        data = service_response.data
        code = service_response.code
        self.body = data
        self.status = ERROR_CODE_TO_HTTP_STATUS[code] || 400
        self.headers['Content-Type'] = 'application/pdf'
      end

      def render_xml(service_response)
        data = service_response.data
        code = service_response.code
        self.body = data
        self.status = ERROR_CODE_TO_HTTP_STATUS[code] || 400
        self.headers['Content-Type'] = 'application/xml'
      end

      private

      def response_body(service_response)
        code = service_response.code
        entity = entity_by_response(service_response.data)

        if service_response.data.is_a?(Atlas::Service::Mechanism::Pagination::QueryResult)
          data = service_response.data.results
        elsif !service_response.success?
          data = { code: code, errors: service_response.data }
        else
          data = service_response.data
        end
        serialize_data(entity, data)
      end

      def entity_by_response(response_data)
        if response_data.respond_to?(:results)
          return [] if response_data.results.empty?
          response_data.results.first.class.name.split('::').last
        else
          response_data.class.name.split('::').last
        end
      end

      def serialize_data(entity, data)
        serializer = BaseController.config.serializers_namespace.const_get("#{entity}Serializer".to_sym)
        serializer.new(data)
      rescue NameError
        data
      end

      def response_headers(data)
        base = { 'Content-Type' => 'application/json' }
        return base unless data.is_a?(Atlas::Service::Mechanism::Pagination::QueryResult)
        base.merge('Total' => data.total.to_s, 'Per-Page' => data.per_page.to_s)
      end
    end
  end
end
