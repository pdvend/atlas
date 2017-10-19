# frozen_string_literal: true

module Atlas
  module Enum
    module Formats
      UUID4 = /[a-f0-9]{8}-[a-f0-9]{4}-4[a-f0-9]{3}-[89ab][a-f0-9]{3}-[a-f0-9]{12}/ix
      VALID_EMAIL = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i
      VALID_PHONE_NUMBER = /^\(\s*(?<ddd>\d\d)\s*\)\s*(?<part1>\d{4,5})\s*(?:\s|\.|-)?\s*(?<part2>\d{4})$/
    end
  end
end
