# frozen_string_literal: true

module Atlas
  module API
    module Context
      module DSL
        def component(name)
          use(Atlas::API::Middleware::ContextAcquirerMiddleware, component: name)
        end
      end
    end
  end
end
