# encoding: utf-8
$LOAD_PATH.unshift File.expand_path(File.dirname(__FILE__))

require 'spec_helper'

describe 'AMQP::Failover::Config' do
  
  before(:each) do
    configs = [
      {:host => 'rabbit0.local'},
      {:host => 'rabbit1.local'},
      {:host => 'rabbit2.local', :port => 5673}
    ]
    @configs = configs.map { |conf| AMQP.settings.merge(conf) }
    @fail = AMQP::Failover.new(@configs)
  end
  
  it "should initialize" do
    fail = AMQP::Failover::Config.new(@configs[0])
    fail.should == @configs[0]
    fail.last_fail.should be_nil
    
    now = Time.now
    fail = AMQP::Failover::Config.new(@configs[1], now)
    fail.should == @configs[1]
    fail.last_fail.should == now
  end
  
  it "should order properly with #<=>" do
    one_hour_ago = (Time.now - 3600)
    two_hours_ago = (Time.now - 7200)

    fail = [ AMQP::Failover::Config.new(@configs[0]),
             AMQP::Failover::Config.new(@configs[1], one_hour_ago),
             AMQP::Failover::Config.new(@configs[2], two_hours_ago) ]
    
    (fail[1] <=> fail[0]).should == -1
    (fail[0] <=> fail[0]).should == 0
    (fail[0] <=> fail[1]).should == 1
    
    (fail[1] <=> fail[2]).should == -1
    (fail[1] <=> fail[1]).should == 0
    (fail[2] <=> fail[1]).should == 1
    
    fail.sort[0].last_fail.should == one_hour_ago
    fail.sort[1].last_fail.should == two_hours_ago
    fail.sort[2].last_fail.should == nil
  end
  
  it "should be ordered by last_fail" do
    result = [ AMQP::Failover::Config.new(@configs[1], (Time.now - 60)),
               AMQP::Failover::Config.new(@configs[2], (Time.now - (60*25))),
               AMQP::Failover::Config.new(@configs[0], (Time.now - 3600)) ]
               
    origin = [ AMQP::Failover::Config.new(@configs[0], (Time.now - 3600)),
               AMQP::Failover::Config.new(@configs[1], (Time.now - 60)),
               AMQP::Failover::Config.new(@configs[2], (Time.now - (60*25))) ]
    origin.sort.should == result
    
    origin = [ AMQP::Failover::Config.new(@configs[0]),
               AMQP::Failover::Config.new(@configs[1], (Time.now - 60)),
               AMQP::Failover::Config.new(@configs[2], (Time.now - (60*25))) ]
    origin.sort.should == result
  end
  
end

