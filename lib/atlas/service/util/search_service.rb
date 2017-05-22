module Atlas
  module Service
    module Util
      module SearchService
        protected

        def format(params, &block)
          response = Atlas::Service::Mechanism::ServiceResponseFormatter.new.format(params, &block)
          response.success ? result_from_success(response) : result_from_failure(response)
        end

        def result_from_success(response)
          Atlas::Service::ServiceResponse.new(data: response.data, code: Enum::ErrorCodes::NONE)
        end

        def result_from_failure(_response)
          Atlas::Service::ServiceResponse.new(
            data: { base: 'Internal Error' },
            code: Enum::ErrorCodes::INTERNAL
          )
        end
      end
    end
  end
end
