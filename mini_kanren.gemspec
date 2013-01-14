# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'mini_kanren/version'

Gem::Specification.new do |gem|
  gem.name          = "mini_kanren"
  gem.version       = MiniKanren::Version::VERSION
  gem.authors       = ["Scott Dial", "Sergey Pariev"]
  gem.email         = ["spariev@gmail.com"]
  gem.description   = %q{MiniKanren implementation in Ruby}
  gem.summary       = %q{MiniKanren implementation in Ruby}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_development_dependency 'rspec', '~> 2.11'
  gem.add_development_dependency 'rake'
end
