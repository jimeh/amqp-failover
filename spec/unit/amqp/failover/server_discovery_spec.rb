# encoding: utf-8
$LOAD_PATH.unshift File.expand_path(File.dirname(__FILE__))

require 'spec_helper'
require 'server_discovery_helper'

describe AMQP::Failover::ServerDiscovery do
  
  before(:each) do
    $called = []
    $start_count = 0
    @args = { :host => 'localhost', :port => 9999, :retry_interval => 0.01 }
  end
  
  it "should initialize" do
    EM.run {
      EM.start_server('127.0.0.1', 9999)
      @mon = ServerDiscoveryHelper.monitor(@args) do
        $called << :done_block
        EM.stop_event_loop
      end
    }
    $start_count.should == 1
    $called.should have(5).items
    $called.uniq.should have(5).items
    $called.should include(:start_monitoring)
    $called.should include(:initialize)
    $called.should include(:connection_completed)
    $called.should include(:close_connection)
    $called.should include(:done_block)
  end
  
  it "should retry on error" do
    EM.run {
      @mon = ServerDiscoveryHelper.monitor(@args) do
        $called << :done_block
        EM.stop_event_loop
      end
    }
    $start_count.should >= 3
    $called.should have($start_count + 4).items
    $called.uniq.should have(5).items
    $called.should include(:start_monitoring)
    $called.should include(:initialize)
    $called.should include(:connection_completed)
    $called.should include(:close_connection)
    $called.should include(:done_block)
  end
  
end
