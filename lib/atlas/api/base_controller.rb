# frozen_string_literal: true

module Atlas
  module API
    module BaseController
      extend Dry::Configurable
      include Atlas::Util::I18nScope
      include Atlas::Service::Util::ResponseHelpers
      setting :serializers_namespaces

      def self.included(base)
        base.class_eval do
          include Hanami::Action
          extend Atlas::API::Context::DSL
        end
      end

      ERROR_CODE_TO_HTTP_STATUS = {
        Atlas::Enum::ErrorCodes::NONE => 200,
        Atlas::Enum::ErrorCodes::AUTHENTICATION_ERROR => 401,
        Atlas::Enum::ErrorCodes::PERMISSION_ERROR => 403,
        Enum::ErrorCodes::RESOURCE_NOT_FOUND => 404
      }.freeze

      FORMAT_TO_RENDERER = {
        json:   Renderer::JsonRenderer,
        xml:    Renderer::XmlRenderer,
        zip:    Renderer::ZipRenderer,
        stream: Renderer::StreamRenderer,
        pdf:    Renderer::PdfRenderer
      }.freeze

      DEFAULT_RENDERER = FORMAT_TO_RENDERER[:json]

      def render(service_response, fmt: :json)
        renderer = FORMAT_TO_RENDERER.fetch(fmt, DEFAULT_RENDERER).new(service_response)
        self.body = renderer.body
        self.status = ERROR_CODE_TO_HTTP_STATUS[service_response.code] || 400
        headers.merge!(renderer.headers)
      end

      def render_not_found
        message = I18n.t(:not_found, scope: 'atlas.api.base_controller')
        response_params = { key: :not_found, code: Enum::ErrorCodes::RESOURCE_NOT_FOUND, message: message }
        service_response = failure_response(response_params)
        self.body = service_response
        self.status = ERROR_CODE_TO_HTTP_STATUS[service_response.code] || 400
      end
    end
  end
end
