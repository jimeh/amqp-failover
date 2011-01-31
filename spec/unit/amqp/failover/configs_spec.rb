# encoding: utf-8
$LOAD_PATH.unshift File.expand_path(File.dirname(__FILE__))

require 'spec_helper'

describe 'AMQP::Failover::Configs' do
  
  before(:each) do
    @conf = AMQP::Failover::Configs.new
    @raw_configs = [
      {:host => 'rabbit3.local'},
      {:host => 'rabbit2.local'},
      {:host => 'rabbit2.local', :port => 5673}
    ]
    @configs = @raw_configs.map { |conf| AMQP.settings.merge(conf) }
  end
  
  it "should set and get configs" do
    @conf.primary.should == 0
    @conf.should have(0).items
    
    @conf.set(@raw_configs[0])
    @conf.should have(1).items
    @conf.get(0).should == @configs[0]
    @conf[0].should == @configs[0]
    
    @conf.set(@raw_configs[1])
    @conf.should have(2).items
    @conf.get(1).should == @configs[1]
    @conf[1].should == @configs[1]
    
    @conf.set(@raw_configs[1], :the_one)
    @conf.should have(2).items
    @conf.get(1).should == @configs[1]
    @conf[:the_one].should == @configs[1]
    
    @conf.load_array(@raw_configs)
    @conf.should have(3).items
    @conf.get_primary.should == @configs[0]
    @conf.primary = 1
    @conf.get_primary.should == @configs[1]
    @conf[:primary].should == @configs[1]
  end
  
  it "should #find_next" do
    @conf.load(@raw_configs)
    @conf.should have(3).items
    @conf.find_next(@configs[0]).should == @configs[1]
    @conf.find_next(@configs[1]).should == @configs[2]
    @conf.find_next(@configs[2]).should == @configs[0]
  end
  
end

