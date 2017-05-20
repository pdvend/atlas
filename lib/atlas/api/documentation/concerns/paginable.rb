module Atlas
  module API
    module Documentation
      module Concerns
        module Paginable
          def self.extended(base)
            page_number(base)
            per_page(base)
          end

          def self.page_number(base)
            base.parameter do
              key :name, :page
              key :in, :query
              key :description, 'Number of page, starting by 1 '
              key :type, :string
            end
          end

          def self.per_page(base)
            base.parameter do
              key :name, :count
              key :in, :query
              key :description, 'Number of registers by page, suject limit in api'
              key :type, :string
            end
          end
        end
      end
    end
  end
end
