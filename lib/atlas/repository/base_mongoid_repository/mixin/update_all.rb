# frozen_string_literal: true

module Atlas
  module Repository
    class BaseMongoidRepository
      module Mixin
        module UpdateAll
          def update(params)
            wrap do
              model.where(params[:query]).update_all(params[:update_params])
              Atlas::Repository::RepositoryResponse.new(data: nil, err_code: Enum::ErrorCodes::NONE)
            end
          end
        end
      end
    end
  end
end
