# frozen_string_literal: true

RSpec.configure do |config|
  require 'atlas/spec/factory_bot'
  config.include FactoryBot::Syntax::Methods

  config.before(:suite) do
    FactoryBot.definition_file_paths = [File.join(File.dirname(__FILE__), 'factories')]
    FactoryBot.find_definitions
  end
end
