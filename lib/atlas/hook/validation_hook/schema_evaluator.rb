# frozen_string_literal: true

module Atlas
  module Hook
    class ValidationHook
      module SchemaEvaluator
        module_function

        def evaluate(_context, params, &block)
          return {} unless params.is_a?(Hash)
          result = schema_for(block).call(params)
          errors_from_result(result)
        end

        def errors_from_result(result)
          result.errors unless result.success?
        end

        def schema_for(block)
          Dry::Validation.Schema do
            configure { config.messages = :i18n }
            instance_eval(&block)
          end
        end
      end
    end
  end
end
