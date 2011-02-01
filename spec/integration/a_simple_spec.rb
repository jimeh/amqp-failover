# encoding: utf-8
$LOAD_PATH.unshift File.expand_path(File.dirname(__FILE__))

require 'spec_helper'
require 'mq'
require 'amqp'
require 'amqp/server'
require 'server_helper'

describe "A simple AMQP connection with FailoverClient loaded" do
  
  after(:all) do
    ServerHelper.clear_logs
  end
  
  it "should be using FailoverClient" do
    AMQP.client.should == AMQP::FailoverClient
  end
  
  it "should be able to connect" do
    EM.run {
      port = 15672
      timeout = 2
      serv = start_server(port)
      EM.add_timer(1.5) {
        conn = AMQP.connect(:host => 'localhost', :port => 15672)
        EM.add_timer(0.1) {
          conn.should be_connected
          serv.stop
          log = serv.log
          log.size.should == 3
          (0..2).each { |i| log[i]['method'].should == "send" }
          log[0]['class'].should == 'AMQP::Protocol::Connection::Start'
          log[1]['class'].should == 'AMQP::Protocol::Connection::Tune'
          log[2]['class'].should == 'AMQP::Protocol::Connection::OpenOk'
          EM.stop
        }
      }
    }
  end
  
  it "should be able to connect and get disconnected" do
    EM.run {
      serv = start_server(25672)
      EM.add_timer(0.1) {
        conn = AMQP.connect(:host => 'localhost', :port => 25672)
        EM.add_timer(0.1) {
          conn.should be_connected
          serv.stop
          EM.add_timer(0.1) {
            conn.should_not be_connected
            EM.stop
          }
        }
      }
    }
  end
  
end
