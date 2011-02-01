# encoding: utf-8
$LOAD_PATH.unshift File.expand_path(File.dirname(__FILE__))

require 'spec_helper'
require 'amqp/server'
require 'server_helper'

describe "Full Failover support of AMQP gem" do
  
  after(:all) do
    ServerHelper.clear_logs
  end
  
  it "should be able to connect" do
    EM.run {
      serv = start_server(15672)
      EM.add_timer(0.1) {
        conn = AMQP.connect(:host => 'localhost', :port => 15672)
        conn.failover.should be_nil
        EM.add_timer(0.1) {
          conn.should be_connected
          EM.stop
        }
      }
    }
  end
  
  it "should be able to connect and failover" do
    EM.run {
      serv1 = start_server(25672)
      serv2 = start_server(35672)
      EM.add_timer(0.1) {
        conn = AMQP.connect({:hosts => [{:port => 25672}, {:port => 35672}]})
        conn.failover.primary[:port].should == 25672
        conn.settings[:port].should == 25672
        conn.settings.should == conn.failover.primary
        EM.add_timer(0.1) {
          conn.should be_connected
          serv1.log.should have(3).items
          serv2.log.should have(0).items
          serv1.stop
          EM.add_timer(0.1) {
            conn.should be_connected
            conn.settings[:port].should == 35672
            serv1.log.should have(3).items
            serv2.log.should have(3).items
            EM.add_timer(0.1) {
              serv2.stop
              EM.stop
            }
          }
        }
      }
    }
  end
  
end
