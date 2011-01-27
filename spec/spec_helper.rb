# encoding: utf-8

# add project-relative load paths
$LOAD_PATH.unshift File.expand_path(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift File.expand_path(File.dirname(__FILE__))

# require stuff
require 'rubygems'

begin
  require 'mq'
rescue LoadError => e
  require 'amqp'
end
require 'amqp/failover'

require 'rspec'
require 'rspec/autorun'
