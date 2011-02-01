$LOAD_PATH.unshift File.expand_path("lib", File.dirname(__FILE__))

require 'bundler'
Bundler::GemHelper.install_tasks


#
# Rspec
#

require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new('spec:all') do |spec|
  spec.pattern = [ 'spec/unit/**/*_spec.rb',
                   'spec/integration/**/*_spec.rb' ]
end

desc "Run unit specs"
task :spec => ["spec:unit"]
RSpec::Core::RakeTask.new('spec:unit') do |spec|
  spec.pattern = 'spec/unit/**/*_spec.rb'
end

RSpec::Core::RakeTask.new('spec:integration') do |spec|
  spec.pattern = 'spec/integration/**/*_spec.rb'
end

RSpec::Core::RakeTask.new(:rcov) do |spec|
  spec.pattern = 'spec/**/*_spec.rb'
  spec.rcov = true
end


#
# Yard
#

begin
  require 'yard'
  YARD::Rake::YardocTask.new
rescue LoadError
  task :yardoc do
    abort "YARD is not available. In order to run yardoc, you must: sudo gem install yard"
  end
end


#
# Misc.
#

desc "Start irb with amqp-failover pre-loaded"
task :console do
  exec "irb -r spec/spec_helper"
end
task :c => :console
