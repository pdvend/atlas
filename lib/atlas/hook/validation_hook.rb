module Atlas
  module Hook
    class ValidationHook
      include Atlas::Util::I18nScope

      VALID_PARAMS = Atlas::Service::ServiceResponse.new(data: {}, code: Enum::ErrorCodes::NONE).freeze
      EVALUATION_METHODS = { raw: :raw_evaluate, schema: :schema_evaluate }.freeze
      DEFAULT_OPTIONS = {
        evaluation: :raw,
        code: Enum::ErrorCodes::VALIDATION,
        message_key: :invalid_params
      }


      def execute(context, params, options = {}, &block)
        opts = DEFAULT_OPTIONS.merge(options)
        evaluation_method = EVALUATION_METHODS[opts[:evaluation]]
        return VALID_PARAMS unless evaluation_method
        method(evaluation_method).call(context, params, opts, &block)
      end

      private

      def raw_evaluate(context, params, options)
        yield(context, params) ? VALID_PARAMS : invalid_params({}, options)
      end

      def schema_evaluate(_context, params, options, &block)
        return invalid_params({}) unless params.is_a?(Hash)
        result = schema_for(block).call(params)
        result.success? ? VALID_PARAMS : invalid_params(result.errors, options)
      end

      def schema_for(block)
        Dry::Validation.Schema do
          configure { config.messages = :i18n }
          instance_eval(&block)
        end
      end

      def invalid_params(errors, options)
        Atlas::Service::ServiceResponse.new(
          message: I18n.t(options[:message_key], scope: i18n_scope),
          data: errors,
          code: options[:code],
        )
      end
    end
  end
end
