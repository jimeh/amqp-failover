# encoding: utf-8
$LOAD_PATH.unshift File.expand_path(File.dirname(__FILE__))

require 'spec_helper'

describe 'AMQP::Failover::Configurations' do
  
  before(:each) do
    @conf = AMQP::Failover::Configurations.new
    @raw_configs = [
      {:host => 'rabbit0.local'},
      {:host => 'rabbit1.local'},
      {:host => 'rabbit2.local', :port => 5673}
    ]
    @configs = @raw_configs.map { |conf| AMQP.settings.merge(conf) }
  end
  
  it "should initialize" do
    confs = AMQP::Failover::Configurations.new(@raw_configs)
    confs.each_with_index do |conf, i|
      conf.should be_a(AMQP::Failover::Config)
      conf.should == @configs[i]
    end
  end
  
  it "should set and get configs" do
    @conf.primary_ref.should == 0
    @conf.should have(0).items
    
    @conf.set(@raw_configs[0])
    @conf.should have(1).items
    @conf.get(0).should == @configs[0]
    @conf[0].should == @configs[0]
    
    @conf.set(@raw_configs[1])
    @conf.should have(2).items
    @conf.get(1).should == @configs[1]
    @conf[1].should == @configs[1]
    
    # should just create a ref, as config exists
    @conf.set(@raw_configs[1], :the_one)
    @conf.should have(2).items
    @conf.get(1).should == @configs[1]
    @conf[:the_one].should == @configs[1]
    
    @conf.load_array(@raw_configs)
    @conf.should have(3).items
    @conf.primary.should == @configs[0]
    @conf.primary_ref = 1
    @conf.primary.should == @configs[1]
    @conf[:primary].should == @configs[1]
  end
  
  it "should #find_next" do
    @conf.load(@raw_configs)
    @conf.should have(3).items
    @conf.find_next(@configs[0]).should == @configs[1]
    @conf.find_next(@configs[1]).should == @configs[2]
    @conf.find_next(@configs[2]).should == @configs[0]
  end
  
  it "should #load_hash" do
    @conf.should have(0).items
    @conf.load_hash(@raw_configs[0])
    @conf.should have(1).items
    @conf.primary.should == @configs[0]
  end
  
  it "should #load_array" do
    @conf.load_hash(:host => 'rabbid-rabbit')
    @conf.should have(1).items
    @conf.load_array(@raw_configs)
    @conf.should have(3).items
    @conf.should == @configs
    @conf.primary.should == @configs[0]
  end
  
end

