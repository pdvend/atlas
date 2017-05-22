module Atlas
  module Spec
    module Mock
      class Service
        def initialize(response)
          @response = response
        end

        def execute(*)
          @response
        end
      end
    end
  end
end
