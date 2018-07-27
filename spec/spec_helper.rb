# frozen_string_literal: true

require 'factory_bot'
require 'coveralls'
require 'webmock/rspec'
require 'timecop'

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
  add_filter 'lib/atlas/spec/'
end

# Set env to test
ENV['APPLICATION_ENV'] ||= 'test'

# Loads gem
require 'atlas'
require 'atlas/spec'

# Spec helpers
Dir['spec/support/helpers/**/*.rb'].each do |file|
  relative_file = file.sub('spec/', '')
  require_relative(relative_file)
end

# Configuration

require 'support/factory_bot'

RSpec.configure do |config|
  config.include Atlas::Spec::SharedExamples::ControllerExamples
  config.include Atlas::Spec::SharedExamples::ServiceExamples
  config.include Atlas::Spec::SharedExamples::RouterExamples
end
