# encoding: utf-8
$LOAD_PATH.unshift File.expand_path(File.dirname(__FILE__))

require 'spec_helper'
require 'amqp/server'
require 'server_helper'

describe "Simple AMQP connection with FailoverClient" do
  
  before(:all) do
    @log = ServerHelper.log
    AMQP.client = AMQP::FailoverClient
  end
  
  it "should be connected" do
    EM.run {
      sig = EM.start_server('localhost', 15672, ServerHelper)
      conn = AMQP.connect(:host => 'localhost', :port => 15672)
      EM.add_timer(0.1) {
        conn.should be_connected
        @log.size.should == 3
        (0..2).each { |i| @log[i][0].should == "send" }
        @log[0][1].payload.should be_a(AMQP::Protocol::Connection::Start)
        @log[1][1].payload.should be_a(AMQP::Protocol::Connection::Tune)
        @log[2][1].payload.should be_a(AMQP::Protocol::Connection::OpenOk)
        EM.stop
      }
    }
  end
  
end
