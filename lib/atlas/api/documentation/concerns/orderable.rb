# frozen_string_literal: true

module Atlas
  module API
    module Documentation
      module Concerns
        module Orderable
          def self.extended(base)
            base.parameter do
              key :name, :order
              key :in, :query
              key :description, 'Query to order results'
              key :type, :string
            end
          end
        end
      end
    end
  end
end
