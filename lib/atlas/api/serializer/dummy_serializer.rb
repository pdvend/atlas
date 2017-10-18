# frozen_string_literal: true

module Atlas
  module API
    module Serializer
      class DummySerializer
        def initialize(data)
          @data = data
        end

        def to_json
          @data.to_json
        end
      end
    end
  end
end
