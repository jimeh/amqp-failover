# encoding: utf-8
$LOAD_PATH.unshift File.expand_path(File.dirname(__FILE__))

require 'spec_helper'

describe 'AMQP::Failover::Config' do
  
  before(:all) do
    # @conf = AMQP::Failover::Config.new
  end
  
  before(:each) do
    @conf = AMQP::Failover::Config.new
    # [:primary, :configs, :refs].each do |var|
    #   @conf.instance_variable_set("@#{var}", nil)
    # end
    @raw_configs = [
      {:host => 'rabbit3.local'},
      {:host => 'rabbit2.local'},
      {:host => 'rabbit2.local', :port => 5673}
    ]
    @configs = @raw_configs.map { |conf| @conf.default_config.merge(conf) }
  end
  
  after(:each) do
    # [:primary, :configs, :refs].each do |var|
    #   @conf.instance_variable_set("@#{var}", nil)
    # end
  end
  
  it "should set and get configs" do
    @conf.primary.should == 0
    @conf.configs.should have(0).items
    
    @conf.set(@raw_configs[0])
    @conf.configs.should have(1).items
    @conf.get(0).should == @configs[0]
    @conf[0].should == @configs[0]
    
    @conf.set(@raw_configs[1])
    @conf.configs.should have(2).items
    @conf.get(1).should == @configs[1]
    @conf[1].should == @configs[1]
    
    @conf.set(@raw_configs[1], :the_one)
    @conf.configs.should have(2).items
    @conf.get(1).should == @configs[1]
    @conf[:the_one].should == @configs[1]
    
    @conf.load_array(@raw_configs)
    @conf.configs.should have(3).items
    @conf.get_primary.should == @configs[0]
    @conf.primary = 1
    @conf.get_primary.should == @configs[1]
    @conf[:primary].should == @configs[1]
  end
  
  it "should #find_next" do
    @conf.load(@raw_configs)
    @conf.configs.should have(3).items
    @conf.find_next(@configs[0]).should == @configs[1]
    @conf.find_next(@configs[1]).should == @configs[2]
    @conf.find_next(@configs[2]).should == @configs[0]
  end
  
end

