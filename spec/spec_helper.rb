# add project-relative load paths
$LOAD_PATH.unshift File.dirname(__FILE__)
$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..', 'lib')

# require stuff
require 'rubygems'
begin
  require 'mq'
rescue Object => e
  require 'amqp'
end
require 'amqp/failover'
require 'rspec'
require 'rspec/autorun'