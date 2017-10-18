# frozen_string_literal: true

module Atlas
  module API
    module Documentation
      module ApiConcerns
        def self.extended(base)
          base.extend(Atlas::API::Documentation::Concerns::Orderable)
          base.extend(Atlas::API::Documentation::Concerns::Filterable)
          base.extend(Atlas::API::Documentation::Concerns::Paginable)
          base.extend(Atlas::API::Documentation::Concerns::Transformable)
        end
      end
    end
  end
end
