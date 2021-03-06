# frozen_string_literal: true

module Atlas
  module Enum
    # :reek:TooManyConstants
    module ErrorCodes
      NONE = 1000

      REPOSITORY_INTERNAL = -1001
      DOCUMENT_NOT_FOUND = -1002
      DOCUMENT_ALREADY_EXISTS = -1003

      INTERNAL = 1001
      VALIDATION = 1002
      PARAMETER_ERROR = 1003
      AUTHENTICATION_ERROR = 1004
      NOT_IMPLEMENTED = 1005
      PERMISSION_ERROR = 1006
      ROUTE_NOT_FOUND = 1007
      RESOURCE_NOT_FOUND = 1008
      RESOURCE_ALREADY_EXISTS = 1009
    end
  end
end
