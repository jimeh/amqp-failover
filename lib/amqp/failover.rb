# encoding: utf-8

require 'yaml'

require 'amqp/failover_client'
require 'amqp/failover/config'
require 'amqp/failover/configurations'
require 'amqp/failover/logger'
require 'amqp/failover/server_discovery'
require 'amqp/failover/version'
require 'amqp/failover/ext/amqp/client.rb'


module AMQP
  class Failover
    
    attr_reader :latest_failed
    attr_accessor :primary
    attr_accessor :retry_timeout
    attr_accessor :fallback
    
    def initialize(confs = nil, opts = {})
      @configs = Failover::Configurations.new(confs)
      @options = default_options.merge(opts)
    end
    
    # pluggable logger specifically for tracking failover and fallbacks
    def self.logger
      @logger ||= Logger.new
    end
    
    def default_options
      { :retry_timeout => 1,
        :selection => :sequential, #TODO: Impliment next server selection algorithm
        :fallback => false, #TODO: Enable by default once a sane solution is found
        :fallback_interval => 10 }
    end
    
    def options
      @options ||= {}
    end
    
    def fallback_interval
      options[:fallback_interval] ||= default_options[:fallback_interval]
    end
    
    def primary
      configs[:primary]
    end
    
    def refs
      @refs ||= {}
    end
    
    def configs
      @configs ||= Configurations.new
    end
    
    def add_config(conf = {}, ref = nil)
      index = configs.index(conf)
      configs << Config::Failed.new(conf) if index.nil?
      refs[ref] = (index || configs.index(conf)) if !ref.nil?
    end
    
    def failover_from(conf = {}, time = nil)
      failed_with(conf, nil, time)
      next_config
    end
    alias :from :failover_from
    
    def failed_with(conf = {}, ref = nil, time = nil)
      time ||= Time.now
      if index = configs.index(conf)
        configs[index].last_fail = time
        @latest_failed = configs[index]
      else
        configs << Config::Failed.new(conf, time)
        @latest_failed = configs.last
      end
      refs[ref] = (index || configs.index(conf)) if !ref.nil?
    end
    
    def next_config(retry_timeout = nil, after = nil)
      return nil if configs.size <= 1
      retry_timeout ||= @options[:retry_timeout]
      after ||= @latest_failed
      index = configs.index(after)
      available = (index > 0) ? configs[index+1..-1] + configs[0..index-1] : configs[1..-1]
      available.each do |conf|
        return conf if conf.last_fail.nil? || (conf.last_fail + retry_timeout.seconds) < Time.now
      end
      return nil
    end
    
    def last_fail_of(match)
      ((match.is_a?(Hash) ? get_by_conf(match) : get_by_ref(match)) || Config::Failed.new).last_fail
    end
    
    def get_by_conf(conf = {})
      configs[configs.index(conf)]
    end
    
    def get_by_ref(ref = nil)
      configs[refs[ref]] if refs[ref]
    end
    
  end # Failover
end # AMQP
