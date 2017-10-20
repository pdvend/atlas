# frozen_string_literal: true

module Atlas
  module API
    module Renderer
      class JsonRenderer < BaseRenderer
        def headers
          super.merge('Content-Type' => 'application/json')
        end

        def body
          super || serializer_instance_to(body_data).to_json
        end

        def serializer_instance_to(data)
          serializer_class_to(data).new(data)
        end

        def serializer_class_to(data)
          return API::Serializer::DummySerializer if data.blank? || data.is_a?(Hash)
          return serializer_class_to(data.first) if data.is_a?(Array)
          entity = data.class.name.split('::').last
          BaseController.config.serializers_namespace.const_get("#{entity}Serializer".to_sym)
        rescue NameError
          API::Serializer::DummySerializer
        end
      end
    end
  end
end
