
# frozen_string_literal: true

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'atlas/version'

Gem::Specification.new do |spec|
  spec.name          = 'atlas'
  spec.version       = Atlas::VERSION
  spec.authors       = ['Gabriel Teles']
  spec.email         = ['gabriel@pdvend.com.br']

  spec.summary       = "PDVend's service's base platform"
  spec.homepage      = 'https://github.com/pdvend/atlas'

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'byebug'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'factory_bot'
  spec.add_development_dependency 'coveralls'
  spec.add_development_dependency 'simplecov'
  spec.add_development_dependency 'webmock'
  spec.add_development_dependency 'timecop'
  spec.add_dependency 'activesupport'
  spec.add_dependency 'aws-sdk', '~> 2'
  spec.add_dependency 'concurrent-ruby'
  spec.add_dependency 'dry-configurable'
  spec.add_dependency 'dry-validation'
  spec.add_dependency 'i18n'
  spec.add_dependency 'ice_nine'
  spec.add_dependency 'json-serializer'
  spec.add_dependency 'rack'
  spec.add_dependency 'hanami-controller'
  spec.add_dependency 'mongoid', '>= 6.1.0', '< 8'
  spec.add_dependency 'pdfkit'
  spec.add_dependency 'httparty'
  spec.add_dependency 'wkhtmltopdf-binpath'
  spec.add_dependency 'delayed_job'
  spec.add_dependency 'delayed_job_mongoid'
  spec.add_dependency 'redis'
  spec.add_dependency 'sidekiq'
end
