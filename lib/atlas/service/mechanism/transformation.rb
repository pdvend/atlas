module Atlas
  module Service
    module Mechanism
      class Transformation
        extend Atlas::Util::I18nScope
        TransformResult = Struct.new(:operation, :field, :result)

        OPERATIONS = %i[sum].freeze
        OPERANTION_PARTS_SEPARATOR = /(#{OPERATIONS.join('|')}):(.*)/

        def self.transformation_params(params, entity)
          return response_error(:invalid_params) unless params && params.is_a?(String)
          raw_statments_parts = params.match(OPERANTION_PARTS_SEPARATOR).to_a
          parts = { operation: raw_statments_parts[1], field: raw_statments_parts[2] }
          response(entity, parts)
        end

        def self.response(entity, parts)
          return response_error(:invalid_operation) unless OPERATIONS.include?(parts[:operation].try(:to_sym))
          return response_error(:invalid_field) unless entity.instance_parameters.include?(parts[:field].try(:to_sym))
          ServiceResponse.new(data: parts, code: Enum::ErrorCodes::NONE)
        end
        private_class_method :response

        def self.response_error(message_key)
          message = I18n.t(message_key, scope: i18n_scope)
          return ServiceResponse.new(message: message, data: {}, code: Enum::ErrorCodes::PARAMETER_ERROR)
        end
        private_class_method :response_error
      end
    end
  end
end
