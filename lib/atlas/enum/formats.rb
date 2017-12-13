# frozen_string_literal: true

module Atlas
  module Enum
    module Formats
      UUID4 = /[a-f0-9]{8}-[a-f0-9]{4}-4[a-f0-9]{3}-[89ab][a-f0-9]{3}-[a-f0-9]{12}/ix
      VALID_EMAIL = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i
      VALID_PHONE_NUMBER = /\d{8,11}/i
    end
  end
end
