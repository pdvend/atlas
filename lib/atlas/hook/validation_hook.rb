module Atlas
  module Hook
    class ValidationHook
      include Atlas::Util::I18nScope

      VALID_PARAMS = Atlas::Service::ServiceResponse.new(data: {}, code: Enum::ErrorCodes::NONE).freeze
      EVALUATION_METHODS = { raw: :raw_evaluate, schema: :schema_evaluate }.freeze

      def execute(context, params, evaluation_type = :raw, &block)
        evaluation_method = EVALUATION_METHODS[evaluation_type]
        return VALID_PARAMS unless evaluation_method
        method(evaluation_method).call(context, params, &block)
      end

      private

      def raw_evaluate(context, params)
        yield(context, params) ? VALID_PARAMS : invalid_params({})
      end

      def schema_evaluate(_context, params, &block)
        return invalid_params({}) unless params.is_a?(Hash)
        result = schema_for(block).call(params)
        result.success? ? VALID_PARAMS : invalid_params(result.errors)
      end

      def schema_for(block)
        Dry::Validation.Schema do
          configure { config.messages = :i18n }
          instance_eval(&block)
        end
      end

      def invalid_params(errors)
        Atlas::Service::ServiceResponse.new(
          message: I18n.t(:invalid_params, scope: i18n_scope),
          data: errors,
          code: Enum::ErrorCodes::VALIDATION,
        )
      end
    end
  end
end
