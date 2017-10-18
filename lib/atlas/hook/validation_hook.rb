# frozen_string_literal: true

module Atlas
  module Hook
    class ValidationHook
      extend Atlas::Util::I18nScope

      VALID_PARAMS = Atlas::Service::ServiceResponse.new(data: {}, code: Enum::ErrorCodes::NONE).freeze
      EVALUATION_METHODS = { raw: RawEvaluator, schema: SchemaEvaluator }.freeze
      DEFAULT_OPTIONS = {
        evaluation: :schema,
        code: Enum::ErrorCodes::VALIDATION,
        message: I18n.t(:invalid_params, scope: i18n_scope)
      }.freeze

      def execute(context, params, options = {}, &block)
        opts = DEFAULT_OPTIONS.merge(options)
        evaluate(context, params, opts, &block)
      end

      private

      def evaluate(context, params, opts, &block)
        evaluator = EVALUATION_METHODS[opts[:evaluation]]
        return VALID_PARAMS unless evaluator
        response = evaluator.evaluate(context, params, &block)
        response ? invalid_params(response, opts) : VALID_PARAMS
      end

      def invalid_params(errors, options)
        Atlas::Service::ServiceResponse.new(message: options[:message], data: errors, code: options[:code])
      end
    end
  end
end
