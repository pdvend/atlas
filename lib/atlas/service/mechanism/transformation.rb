module Atlas
  module Service
    module Mechanism
      class Transformation
        extend Atlas::Util::I18nScope
        TransformResult = Struct.new(:operation, :field, :result)

        OPERATIONS = %i[sum count].freeze
        OPERANTION_PARTS_SEPARATOR = /(#{OPERATIONS.join('|')}):(.*)/

        def self.transformation_params(params, entity)
          return response_error(:invalid_params) unless params.is_a?(Symbol) || params.is_a?(String)
          parts = params.to_sym == :count ? { operation: params.to_sym } : raw_statments_parts(params)
          response(entity, parts)
        end

        def self.raw_statments_parts(params)
          raw_parts = params.match(OPERANTION_PARTS_SEPARATOR).to_a
          operation = raw_parts[1].try(:to_sym)
          parts = { operation: operation }
          parts[:field] = raw_parts[2].try(:to_sym) unless operation == :count
          parts
        end

        def self.response(entity, parts)
          operation = parts[:operation]
          return response_error(:invalid_operation) unless OPERATIONS.include?(operation.try(:to_sym))
          return response_error(:invalid_field) unless operation == :count || entity.instance_parameters.include?(parts[:field].try(:to_sym))
          ServiceResponse.new(data: parts, code: Enum::ErrorCodes::NONE)
        end
        private_class_method :response

        def self.response_error(message_key)
          message = I18n.t(message_key, scope: i18n_scope)
          ServiceResponse.new(message: message, data: {}, code: Enum::ErrorCodes::PARAMETER_ERROR)
        end
        private_class_method :response_error
      end
    end
  end
end
