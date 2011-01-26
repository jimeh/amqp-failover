# encoding: utf-8

module AMQP
  module Failover
    class Logic
      
      attr_reader :latest_failed
      attr_accessor :primary
      attr_accessor :retry_timeout
      attr_accessor :fallback
      
      def initialize(confs = nil, primary = nil, options = {})
        @primary = primary
        @retry_timeout = (options.delete(:retry_timeout) || 30)
        self.configs = confs if !confs.nil?
      end
      
      def refs
        @refs ||= {}
      end
      
      def configs
        @configs ||= []
      end
      
      def configs=(confs = [])
        @configs = []
        confs.each do |conf|
          if conf.is_a?(Array)
            add_config(conf[1], conf[0])
          else
            add_config(conf)
          end
        end
      end
      
      def add_config(conf = {}, ref = nil)
        index = configs.index(conf)
        configs << FailedConfig.new(conf) if index.nil?
        refs[ref] = (index || configs.index(conf)) if !ref.nil?
      end
      
      def failover_from(conf = {}, time = nil)
        failed_with(conf, nil, time)
        next_config
      end
      
      def failed_with(conf = {}, ref = nil, time = nil)
        time ||= Time.now
        if index = configs.index(conf)
          configs[index].last_fail = time
          @latest_failed = configs[index]
        else
          configs << FailedConfig.new(conf, time)
          @latest_failed = configs.last
        end
        refs[ref] = (index || configs.index(conf)) if !ref.nil?
      end
      
      def next_config(retry_timeout = nil, after = nil)
        return nil if configs.size <= 1
        retry_timeout ||= @retry_timeout
        after ||= @latest_failed
        index = configs.index(after)
        available = (index > 0) ? configs[index+1..-1] + configs[0..index-1] : configs[1..-1]
        available.each do |conf|
          return conf if conf.last_fail.nil? || (conf.last_fail + retry_timeout.seconds) < Time.now
        end
        return nil
      end
      
      def last_fail_of(match)
        ((match.is_a?(Hash) ? get_by_conf(match) : get_by_ref(match)) || FailedConfig.new).last_fail
      end 
      
      def get_by_conf(conf = {})
        configs[configs.index(conf)]
      end
      
      def get_by_ref(ref = nil)
        configs[refs[ref]] if refs[ref]
      end
      
    end # Logic
  end # Failover
end # AMQP
