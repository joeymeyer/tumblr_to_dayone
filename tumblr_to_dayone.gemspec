# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'tumblr_to_dayone/version'

Gem::Specification.new do |spec|
  spec.name          = "tumblr_to_dayone"
  spec.version       = TumblrToDayone::VERSION
  spec.authors       = ["Joey Meyer"]
  spec.email         = ["jmeyer41@gmail.com"]
  spec.description   = "Command prompt which makes it easy to add Tumblr posts to your Day One journal."
  spec.summary       = "A simple command prompt that easily allows you to add posts from a Tumblr blog to your Day One journal." 
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"

  spec.add_dependency "reverse_markdown", "~> 0.4"
end
