# encoding: utf-8
$LOAD_PATH.unshift File.expand_path(File.dirname(__FILE__))

require 'spec_helper'

describe 'AMQP::Failover' do
  
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
    @fail.configs.should == @configs
  end
  
  it "should #add_config" do
    @fail.instance_variable_set("@configs", nil)
    @fail.configs.should == []
    @fail.add_config(@configs[0])
    @fail.configs.should have(1).item
    @fail.configs.should == [@configs[0]]
    @fail.refs.should == {}
    @fail.add_config(@configs[1], :hello)
    @fail.configs.should have(2).items
    @fail.configs.should include(@configs[1])
    @fail.get_by_ref(:hello).should == @configs[1]
  end
  
  it "should #get_by_conf" do
    fetched = @fail.get_by_conf(@configs[1])
    fetched.should == @configs[1]
    fetched.class.should == AMQP::Failover::Config
    fetched.last_fail.should be_nil
  end
  
  it "should #fail_with" do
    fail = AMQP::Failover.new
    now = Time.now
    fail.failed_with(@configs[0], 0, now)
    fail.latest_failed.should == @configs[0]
    fail.last_fail_of(@configs[0]).should == now
    fail.last_fail_of(0).should == now
  end
  
  it "should find #next_config" do
    @fail.failed_with(@configs[1])
    @fail.next_config.should == @configs[2]
    @fail.next_config.should == @configs[2]
    @fail.failed_with(@configs[2])
    @fail.next_config.should == @configs[0]
    @fail.failed_with(@configs[0])
    @fail.next_config.should be_nil
  end
  
  it "should #failover_from" do
    now = Time.now
    @fail.failover_from(@configs[0], now).should == @configs[1]
    @fail.latest_failed.should == @configs[0]
    @fail.latest_failed.last_fail.should == now
  end
  
end

