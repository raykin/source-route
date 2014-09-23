# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'source_route/version'

Gem::Specification.new do |spec|
  spec.name          = "source_route"
  spec.version       = SourceRoute::VERSION
  spec.authors       = ["raykin"]
  spec.email         = ["raykincoldxiao@gmail.com"]
  spec.summary       = %q{Wrapper of TracePoint.}
  spec.description   = %q{Wrapper of TracePoint.}
  spec.homepage      = "http://github.com/raykin/source-route"
  spec.license       = "MIT"
  spec.required_ruby_version = '>= 2'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency 'awesome_print'
  spec.add_dependency 'colorize'
  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"
  spec.add_development_dependency 'slim'
end
