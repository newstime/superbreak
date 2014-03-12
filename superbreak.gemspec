# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = "superbreak"
  spec.version       = "0.0.1"
  spec.authors       = ["Blake Taylor"]
  spec.email         = ["blakefrost@gmail.com"]
  spec.description   = %q{Breaks Paragraphs into Lines.}
  spec.summary       = %q{
    Typesetting tools which allow the breaking for paragraphs into lines.
  }
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"

  #spec.add_runtime_dependency 'crawdad', '~> 0.1.0'
  spec.add_runtime_dependency 'nokogiri', '~> 1.6.0'
  spec.add_runtime_dependency 'json', '~> 1.8.1'

end
