# encoding: utf-8

module AMQP
  module Failover
    module BasicClient
      include AMQP::BasicClient
      
      class Error < Exception; end
      
      attr_accessor :on_disconnect
      attr_accessor :settings
      
      def self.extended(base)
        base.on_disconnect = proc {
          OnDisconnect.new(base).call
        }
      end
      
      def logger
        @logger ||= Logger.new
      end
      
      def failover_conf
        @failover_conf ||= Config.new
      end
      
      def configs
        failover_conf.configs
      end
      
      def clean_exit(msg = nil)
        msg ||= "clean exit"
        logger.info(msg)
        logger.error(msg)
        Process.exit
      end
      
      def process_frame(frame)
        if mq = channels[frame.channel]
          mq.process_frame(frame)
          return
        end
        
        if frame.is_a?(::AMQP::Frame::Method) && (method = frame.payload).is_a?(::AMQP::Protocol::Connection::Close)
          if method.reply_text =~ /^NOT_ALLOWED/
            raise ::AMQP::Error, "#{method.reply_text} in #{::AMQP::Protocol.classes[method.class_id].methods[method.method_id]}"
          end
        end
        super(frame)
      end
      
    end # BasicClient
  end # Failover
end # AMQP

