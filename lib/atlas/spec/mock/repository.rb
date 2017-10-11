# frozen_string_literal: true

module Atlas
  module Spec
    module Mock
      class Repository
        def initialize(responses)
          @responses = responses || {}
        end

        def method_missing(name, *args, &block)
          return super unless @responses.key?(name)
          res = @responses[name]
          res.is_a?(Proc) ? res.call(*args, &block) : res
        end

        def respond_to_missing?(name)
          @responses[name].present?
        end
      end
    end
  end
end
