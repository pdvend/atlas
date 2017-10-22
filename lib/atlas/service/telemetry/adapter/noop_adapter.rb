# frozen_string_literal: true

module Atlas
  module Service
    module Telemetry
      module Adapter
        class NoopAdapter
          # :reek:UtilityFunction
          def log(_type, _data)
            # DO NOTHING
            ServiceResponse.new(data: nil, code: Enum::ErrorCodes::NONE)
          end
        end
      end
    end
  end
end
