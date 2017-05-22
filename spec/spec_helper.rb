require 'factory_girl'
require 'support/factory_girl'
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
end

# Set env to test
ENV['APPLICATION_ENV'] = 'test'

# Loads gem
require 'atlas'

# Shared Examples
Dir['spec/support/shared_examples/**/*.rb'].each do |file|
  relative_file = file.sub('spec/', '')
  require_relative(relative_file)
end

Dir['spec/**/*_shared_examples.rb'].each do |file|
  relative_file = file.sub('spec/', '')
  require_relative(relative_file)
end

# Spec helpers
Dir['spec/support/helpers/**/*.rb'].each do |file|
  relative_file = file.sub('spec/', '')
  require_relative(relative_file)
end
