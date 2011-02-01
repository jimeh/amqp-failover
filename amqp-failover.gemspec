# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "amqp/failover/version"

Gem::Specification.new do |s|
  s.name        = "amqp-failover"
  s.version     = AMQP::Failover::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Jim Myhrberg"]
  s.email       = ["contact@jimeh.me"]
  s.homepage    = 'http://github.com/jimeh/amqp-failover'
  s.summary     = 'Add multi-server failover and fallback to amqp gem.'
  s.description = 'Add multi-server failover and fallback to amqp gem.'

  s.rubyforge_project = "amqp-failover"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
  
  s.add_runtime_dependency 'amqp', '>= 0.7.0'
  
  s.add_development_dependency 'rake', '>= 0.8.7'
  s.add_development_dependency 'rspec', '>= 2.1.0'
  s.add_development_dependency 'yard', '>= 0.6.3'
  s.add_development_dependency 'json', '>= 1.5.0'
  s.add_development_dependency 'ruby-debug'
end
