# frozen_string_literal: true

module Atlas
  module Hook
    class ValidationHook
      module RawEvaluator
        module_function

        def evaluate(context, params)
          evaluation = yield(context, params)
          return {} unless evaluation
        end
      end
    end
  end
end
