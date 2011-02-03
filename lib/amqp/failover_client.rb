# encoding: utf-8

module AMQP
  module FailoverClient
    include AMQP::BasicClient
    
    attr_accessor :failover
    attr_reader :fallback_monitor
    
    attr_accessor :settings
    attr_accessor :on_disconnect
    
    def failover_switch
      if (new_settings = @failover.from(@settings))
        log_message = "Could not connect to or lost connection to server #{@settings[:host]}:#{@settings[:port]}. " +
                      "Attempting connection to: #{new_settings[:host]}:#{new_settings[:port]}"
        logger.error(log_message)
        logger.info(log_message)
        
        if @failover.options[:fallback] && @failover.primary == @settings
          fallback(@failover.primary, @failover.fallback_interval)
        end
        @settings = new_settings.merge({:failover => @failover})
        reconnect
      else
        raise Error, "Could not connect to server #{@settings[:host]}:#{@settings[:port]}"
      end
    end
    
    def logger
      Failover.logger
    end
    
    def configs
      @failover.configs if @failover
    end
    
    def clean_exit(msg = nil)
      msg ||= "clean exit"
      logger.info(msg)
      logger.error(msg)
      Process.exit
    end
    
    def fallback(conf = {}, retry_interval = nil)
      @fallback_monitor = Failover::ServerDiscovery.monitor(conf, retry_interval) do
        fallback_callback.call(conf, retry_interval)
      end
    end
    
    def fallback_callback
      #TODO: Figure out a way to artificially trigger EM to disconnect on fallback without channels being closed.
      @fallback_callback ||= proc { |conf, retry_interval|
        clean_exit("Primary server (#{conf[:host]}:#{conf[:port]}) is back. " +
                   "Performing clean exit to be relaunched with primary config.")
      }
    end
    attr_writer :fallback_callback
    
    #TODO: Figure out why I originally needed this
    # def process_frame(frame)
    #   if mq = channels[frame.channel]
    #     mq.process_frame(frame)
    #     return
    #   end
    #   
    #   if frame.is_a?(AMQP::Frame::Method) && (method = frame.payload).is_a?(AMQP::Protocol::Connection::Close)
    #     if method.reply_text =~ /^NOT_ALLOWED/
    #       raise AMQP::Error, "#{method.reply_text} in #{::AMQP::Protocol.classes[method.class_id].methods[method.method_id]}"
    #     end
    #   end
    #   super(frame)
    # end
    
  end # FailoverClient
end # AMQP

