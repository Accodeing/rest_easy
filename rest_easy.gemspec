# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rest_easy/version'

Gem::Specification.new do |spec| # rubocop:disable Metrics/BlockLength
  spec.name          = "rest-easy"
  spec.version       = RestEasy::VERSION
  spec.authors       = ["Jonas Schubert Erlandsson", "Hannes Elvemyr", "Felix Holmgren"]
  spec.email         = ["info@accodeing.com"]
  spec.summary       = "Boilerplate for REST API libraries."
  spec.description   = "Contains a lot of the boilerplate you need to implement a REST API library."
  spec.homepage      = "http://github.com/accodeing/rest-easy"
  spec.licenses      = ['GPL-3.0', 'Commercial']

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}){ |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(spec)/})
  spec.require_paths = ["lib"]

  spec.required_ruby_version = '> 2.2'
  spec.add_dependency "faraday", "~> 0.15"
  spec.add_dependency "dry-struct", "~> 0.6"
  spec.add_dependency "dry-validation", "~> 0.12"

  spec.add_development_dependency "bundler", "~> 1.9"
  spec.add_development_dependency "rake", "~> 10.4"
  spec.add_development_dependency "rspec", "~> 3.2"
  spec.add_development_dependency "rspec-collection_matchers", "~> 0"
  spec.add_development_dependency "guard", "~> 2.12"
  spec.add_development_dependency "guard-rspec", "~> 4.5"
  spec.add_development_dependency "webmock", "~> 1.21"
  spec.add_development_dependency "pry", "~> 0"
  spec.add_development_dependency "codeclimate-test-reporter", "~> 0"
  spec.add_development_dependency "rubocop", "~> 0.54"
  spec.add_development_dependency "rubocop-rspec", "~> 1.8"

end
