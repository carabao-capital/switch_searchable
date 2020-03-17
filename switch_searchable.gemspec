# coding: utf-8
# frozen_string_literal: true

lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "switch_searchable/version"

Gem::Specification.new do |spec|
  spec.name          = "switch_searchable"
  spec.version       = SwitchSearchable::VERSION
  spec.authors       = ["Neil Marion dela Cruz"]
  spec.email         = ["nmfdelacruz@gmail.com"]

  spec.summary       = "Manages different search engines in a Rails app"
  spec.description   = "Manages different search engines in a Rails app"
  spec.homepage      = "https://github.com/carabao-capital/switch_searchable"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "pg_search", "2.1.0"
  spec.add_runtime_dependency "algoliasearch-rails", "~> 1.20.1", ">= 1.20.1"
  spec.add_runtime_dependency "elasticsearch-model", "~> 5.0.1", ">= 5.0.1"
  spec.add_runtime_dependency "elasticsearch-rails", "~> 5.0.1", ">= 5.0.1"
  spec.add_runtime_dependency "activejob"

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
