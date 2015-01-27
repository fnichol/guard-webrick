# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "guard/webrick/version"

Gem::Specification.new do |s|
  s.name        = "guard-webrick"
  s.version     = Guard::WEBrickVersion::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ['Fletcher Nichol']
  s.email       = ['fnichol@nichol.ca']
  s.homepage    = 'http://rubygems.org/gems/guard-webrick'
  s.summary     = %q{Guard gem for WEBrick}
  s.description = %q{Guard::WEBrick automatically starts and restarts WEBrick when needed.}

  s.required_rubygems_version = '>= 1.3.6'
  s.rubyforge_project = "guard-webrick"

  s.add_dependency 'guard', '>= 1.0'
  s.add_dependency 'spoon', '~> 0.0.1'
  s.add_dependency 'ffi'
  s.add_dependency 'launchy', '~> 2.1.0'

  s.add_development_dependency 'rspec', '~> 2.5'
  s.add_development_dependency 'guard-rspec'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
