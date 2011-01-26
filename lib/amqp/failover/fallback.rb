# encoding: utf-8

module AMQP
  module Failover
    class Fallback < EM::Connection
      
      class << self
        attr_accessor :connection
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
      
      def self.monitor(conf = {}, &block)
        if EM.reactor_running?
          start_monitoring(conf, &block)
        else
          EM.run { start_monitoring(conf, &block) }
        end
      end
      
      def self.start_monitoring(conf = {}, &block)
        conf = conf.clone
        conf[:done] = block
        conf[:timer] = EM::PeriodicTimer.new(conf[:retry_interval] || 5) do
          @connection = connect(conf)
        end
      end
      
      def self.connect(conf)
        EM.connect(conf[:host], conf[:port], self, conf)
      end
      
    end # Fallback
  end # Failover
end # AMQP
