module Platform
  module Service
    module Telemetry
      module Adapter
        class StdoutAdapter
          def log(type, data)
            puts(type: type, data: data)
            ServiceResponse.new(data: nil, code: Enum::ErrorCodes::NONE)
          end
        end
      end
    end
  end
end
