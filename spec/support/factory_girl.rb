RSpec.configure do |config|
  config.include FactoryGirl::Syntax::Methods

  config.before(:suite) do
    FactoryGirl.definition_file_paths = [File.join(File.dirname(__FILE__), 'factories')]
    FactoryGirl.find_definitions
  end
end
