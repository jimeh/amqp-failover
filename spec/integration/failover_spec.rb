# encoding: utf-8
$LOAD_PATH.unshift File.expand_path(File.dirname(__FILE__))

require 'spec_helper'
require 'amqp/server'
require 'server_helper'
require 'logger_helper'

describe "Full Failover support of AMQP gem" do
  
  before(:each) do
    @flog = LoggerHelper.new
    AMQP::Failover.logger = @flog
  end
  
  after(:each) do
    ServerHelper.clear_logs
    AMQP::Failover.logger = nil
  end
  
  it "should be able to connect" do
    port1 = 15672
    EM.run {
      serv = start_server(port1)
      EM.add_timer(0.1) {
        conn = AMQP.connect(:host => 'localhost', :port => port1)
        conn.failover.should be_nil
        EM.add_timer(0.1) {
          conn.should be_connected
          EM.stop
        }
      }
    }
  end
  
  it "should be able to connect and failover" do
    port1 = 25672
    port2 = 35672
    EM.run {
      # start mock amqp servers
      serv1 = start_server(port1)
      serv2 = start_server(port2)
      EM.add_timer(0.1) {
        # start amqp client connection and make sure it's picked the right config
        conn = AMQP.connect({:hosts => [{:port => port1}, {:port => port2}]})
        conn.failover.primary[:port].should == port1
        conn.settings[:port].should == port1
        conn.settings.should == conn.failover.primary
        EM.add_timer(0.1) {
          # make sure client connected to the correct server, then kill server
          conn.should be_connected
          serv1.log.should have(3).items
          serv2.log.should have(0).items
          serv1.stop
          EM.add_timer(0.1) {
            # make sure client performed a failover when primary server died
            conn.should be_connected
            [:error, :info].each do |i|
              @flog.send("#{i}_log").should have(1).item
              @flog.send("#{i}_log")[0][0].should match(/connect to or lost connection.+#{port1}.+attempting connection.+#{port2}/i)
            end
            conn.settings[:port].should == port2
            serv1.log.should have(3).items
            serv2.log.should have(3).items
            conn.close
            EM.add_timer(0.1) {
              serv2.stop
              EM.stop
            }
          }
        }
      }
    }
  end
  
  it "should be able to fallback when primary server returns" do
    port1 = 45672
    port2 = 55672
    lambda {
      EM.run {
        # start mock amqp servers
        serv1 = start_server(port1)
        serv2 = start_server(port2)
        EM.add_timer(0.1) {
          # start amqp client connection and make sure it's picked the right config
          conn = AMQP.connect({:hosts => [{:port => port1}, {:port => port2}], :fallback => true, :fallback_interval => 0.1})
          conn.failover.primary[:port].should == port1
          conn.settings[:port].should == port1
          conn.settings.should == conn.failover.primary
          EM.add_timer(0.1) {
            # make sure client connected to the correct server, then kill server
            conn.should be_connected
            serv1.log.should have(3).items
            serv2.log.should have(0).items
            serv1.stop
            EM.add_timer(0.1) {
              # make sure client performed a failover when primary server died
              conn.should be_connected
              [:error, :info].each do |i|
                @flog.send("#{i}_log").should have(1).item
                @flog.send("#{i}_log")[0][0].should match(/connect to or lost connection.+#{port1}.+attempting connection.+#{port2}/i)
              end
              conn.settings[:port].should == port2
              serv1.log.should have(3).items
              serv2.log.should have(3).items
              serv3 = start_server(port1)
              EM.add_timer(0.2) {
                # by this point client should have raised a SystemExit exception
                serv2.stop
                EM.stop
              }
            }
          }
        }
      }
    }.should raise_error(SystemExit, "exit")
    [:error, :info].each do |i|
      @flog.send("#{i}_log").should have(2).item
      @flog.send("#{i}_log")[1][0].should match(/primary server.+45672.+performing clean exit/i)
    end
  end
  
end
