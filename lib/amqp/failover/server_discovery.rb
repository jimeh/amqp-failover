# encoding: utf-8

module AMQP
  class Failover
    class ServerDiscovery < EM::Connection
      
      class << self
        attr_accessor :connection
      end
      
      def self.monitor(conf = {}, retry_interval = nil, &block)
        if EM.reactor_running?
          start_monitoring(conf, retry_interval, &block)
        else
          EM.run { start_monitoring(conf, retry_interval, &block) }
        end
      end
      
      def initialize(args)
        @done = args[:done]
        @timer = args[:timer]
      end
      
      def connection_completed
        @done.call
        @timer.cancel
        close_connection
      end
            
      def self.start_monitoring(conf = {}, retry_interval = nil, &block)
        conf = conf.clone
        retry_interval ||= 5
        conf[:done] = block
        conf[:timer] = EM::PeriodicTimer.new(retry_interval) do
          @connection = connect(conf)
        end
      end
      
      def self.connect(conf)
        EM.connect(conf[:host], conf[:port], self, conf)
      end
      
    end # ServerDiscovery
  end # Failover
end # AMQP
