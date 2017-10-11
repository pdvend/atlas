# frozen_string_literal: true

module Atlas
  module Service
    module Mechanism
      class Transformation
        extend Atlas::Util::I18nScope
        extend Atlas::Service::Util::ResponseHelpers
        TransformResult = Struct.new(:operation, :field, :result)

        PARAMETERIZED_OPERATIONS = %i[sum].freeze
        NON_PARAMETERIZED_OPERATIONS = %i[count].freeze
        PARAMETERIZED_MATCHER = /(?<operation>#{PARAMETERIZED_OPERATIONS.join('|')}):(?<field>.*)/
        NON_PARAMETERIZED_MATCHER = /(?<operation>#{NON_PARAMETERIZED_OPERATIONS.join('|')})/
        OPERATION_PARTS_SEPARATOR = /^(?:(?:#{PARAMETERIZED_MATCHER}|#{NON_PARAMETERIZED_MATCHER}))$/i

        PARAMETER_ERROR_CODE = Atlas::Enum::ErrorCodes::PARAMETER_ERROR

        def self.transformation_params(params, entity)
          unless params.is_a?(Symbol) || params.is_a?(String)
            return failure_response(key: :invalid_params, code: PARAMETER_ERROR_CODE)
          end

          raw_statments_parts(OPERATION_PARTS_SEPARATOR.match(params), entity)
        end

        def self.raw_statments_parts(raw_parts, entity)
          operation = raw_parts.try(:[], :operation).try(:to_sym)
          unless valid_operation?(operation)
            return failure_response(key: :invalid_operation, code: PARAMETER_ERROR_CODE)
          end
          parts = { operation: operation }
          return successful_response(parts) if non_parameterized_operation?(operation)
          add_field_part(entity, parts, raw_parts[:field].try(:to_sym))
        end
        private_class_method :raw_statments_parts

        def self.add_field_part(entity, parts, field)
          return failure_response(key: :invalid_field, code: PARAMETER_ERROR_CODE) unless valid_field?(entity, field)
          parts[:field] = field
          successful_response(parts)
        end
        private_class_method :add_field_part

        def self.valid_operation?(operation)
          PARAMETERIZED_OPERATIONS.include?(operation.try(:to_sym)) || non_parameterized_operation?(operation)
        end
        private_class_method :valid_operation?

        def self.non_parameterized_operation?(operation)
          NON_PARAMETERIZED_OPERATIONS.include?(operation.try(:to_sym))
        end
        private_class_method :non_parameterized_operation?

        def self.valid_field?(entity, field)
          entity.instance_parameters.include?(field.try(:to_sym))
        end
      end
    end
  end
end
