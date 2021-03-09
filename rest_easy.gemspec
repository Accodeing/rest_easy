# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rest_easy/version'

Gem::Specification.new do |spec| # rubocop:disable Metrics/BlockLength
  spec.name          = "rest-easy"
  spec.version       = RestEasy::VERSION
  spec.authors       = ["Jonas Schubert Erlandsson", "Hannes Elvemyr"]
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
  spec.add_dependency "faraday", "~> 1.3"
  spec.add_dependency "dry-configurable", "~> 0.11"
  spec.add_dependency "dry-struct", "~> 1.0"

  spec.add_development_dependency "bundler", "~> 2.2"
  spec.add_development_dependency "rspec", "~> 3.10"
  spec.add_development_dependency "rspec-its", "~> 1.3.0"
  spec.add_development_dependency "guard", "~> 2.16"
  spec.add_development_dependency "guard-rspec", "~> 4.7"
  spec.add_development_dependency "webmock", "~> 3.12"
  spec.add_development_dependency "pry", "~> 0.14"
  spec.add_development_dependency "rubocop", "~> 1.11"
  spec.add_development_dependency "rubocop-rspec", "~> 2.2"
  spec.add_development_dependency 'ibsciss-middleware', '~> 0.4'
end
