module Atlas
  module API
    module BaseController
      extend Dry::Configurable
      setting :serializers_namespace

      def self.included(base)
        base.class_eval do
          include Hanami::Action
          extend Atlas::API::Context::DSL
        end
      end

      MODULE_SEPARATOR = '::'.freeze
      DEFAULT_ENCODING = 'utf-8'.freeze

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

      def render_stream(service_response)
        data = service_response.data
        code = service_response.code
        self.body = response_stream_body(service_response)
        self.status = ERROR_CODE_TO_HTTP_STATUS[code] || 400
      end

      def render_pdf(service_response)
        return render(service_response) if service_response.code != Enum::ErrorCodes::NONE
        data = service_response.data.force_encoding(DEFAULT_ENCODING)
        code = service_response.code
        self.body = data
        self.status = ERROR_CODE_TO_HTTP_STATUS[code] || 400
        self.headers['Content-Type'] = 'application/pdf'
      end

      def render_xml(service_response)
        return render(service_response) if service_response.code != Enum::ErrorCodes::NONE
        data = service_response.data
        code = service_response.code
        self.body = data
        self.status = ERROR_CODE_TO_HTTP_STATUS[code] || 400
        self.headers['Content-Type'] = 'application/xml'
      end

      private

      def response_stream_body(service_response)
        data = service_response.data
        return data if data.is_a?(Enumerator)
        headers.merge!(response_headers(data))
        Enumerator.new do |yielder|
          yielder << response_body(service_response).to_json
        end
      end

      def response_body(service_response)
        code = service_response.code

        if service_response.data.is_a?(Atlas::Service::Mechanism::Pagination::QueryResult)
          data = service_response.data.results
        elsif !service_response.success?
          data = { code: code, message: service_response.message, errors: service_response.data }
        else
          data = service_response.data
        end

        serializer_instance_to(data)
      end

      def serializer_instance_to(data)
        serializer_class_to(data).new(data)
      end

      def serializer_class_to(data)
        return API::Serializer::DummySerializer if data.blank? || data.is_a?(Hash)
        return serializer_class_to(data.first) if data.is_a?(Array)
        entity = data.class.name.split(MODULE_SEPARATOR).last
        BaseController.config.serializers_namespace.const_get("#{entity}Serializer".to_sym)
      rescue NameError
        API::Serializer::DummySerializer
      end

      def response_headers(data)
        base = { 'Content-Type' => 'application/json' }
        return base unless data.is_a?(Atlas::Service::Mechanism::Pagination::QueryResult)
        base.merge('Total' => data.total.to_s, 'Per-Page' => data.per_page.to_s)
      end
    end
  end
end
