require 'factory_girl'
require 'coveralls'
require 'webmock/rspec'
require 'timecop'
require 'rspec/core/shared_context'
Coveralls.wear!

# Simplecov setup
require 'simplecov'

SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter.new([
  SimpleCov::Formatter::HTMLFormatter,
  Coveralls::SimpleCov::Formatter
])

SimpleCov.start do
  filters.clear

  add_filter { |src| src.filename !~ /^#{SimpleCov.root}\/lib/ }
end

# Set env to test
ENV['APPLICATION_ENV'] ||= 'test'

# Loads gem
require 'atlas'

# Spec helpers
Dir['spec/support/helpers/**/*.rb'].each do |file|
  relative_file = file.sub('spec/', '')
  require_relative(relative_file)
end

# Configuration

require 'support/factory_girl'

RSpec.configure do |config|
  puts Atlas::Spec::SharedExamples::ServiceExamples
  config.include Atlas::Spec::SharedExamples::ControllerExamples
  config.include Atlas::Spec::SharedExamples::ServiceExamples
end
