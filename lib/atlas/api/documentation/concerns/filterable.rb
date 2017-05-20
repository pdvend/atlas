module Atlas
  module API
    module Documentation
      module Concerns
        module Filterable
          def self.extended(base)
            base.parameter do
              key :name, :filter
              key :in, :query
              key :description, 'Query to filter results'
              key :type, :string
            end
          end
        end
      end
    end
  end
end
