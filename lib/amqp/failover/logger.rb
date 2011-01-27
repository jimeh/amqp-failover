# encoding: utf-8

module AMQP
  module Failover
    class Logger
      
      attr_accessor :enabled
      
      def initialize(enabled = nil)
        @enabled = enabled || true
      end
      
      def error(*msg)
        msg[0] = "[ERROR]: " + msg[0] if msg[0].is_a?(String)
        write(*msg)
      end
      
      def info(*msg)
        write(*msg)
      end
      
      private
      
      def write(*msg)
        return if !@enabled
        puts *msg
      end
      
    end # Logger
  end # Failover
end # AMQP
