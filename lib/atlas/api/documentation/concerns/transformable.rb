# frozen_string_literal: true

module Atlas
  module API
    module Documentation
      module Concerns
        module Transformable
          def self.extended(base)
            base.parameter do
              key :name, :transform
              key :in, :query
              key :description, 'Query to transform results'
              key :type, :string
            end
          end
        end
      end
    end
  end
end
