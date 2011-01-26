# encoding: utf-8

module AMQP
  module Failover
    module BasicClient
      class OnDisconnect
        
        attr_accessor :base
        attr_accessor :failover
        attr_accessor :configs
        attr_accessor :logger
        
        def initialize(base)
          @base = base
          @configs = @base.configs
          @failover_conf = @base.failover_conf
          @logger = @base.logger
        end
        
        def call
          @logic ||= Logic.new(@configs.configs, @failover_conf.get_primary, @failover_conf.failover_config)
          if (new_settings = @logic.failover_from(@base.settings))
            log_message = "Could not connect to or lost connection to server #{@base.settings[:host]}:#{@base.settings[:port]}. " +
                          "Attempting connection to: #{new_settings[:host]}:#{new_settings[:port]}"
            @logger.error(log_message)
            @logger.info(log_message)
            
            if @failover_conf.get_primary == @base.settings
              FallbackMonitor.monitor(@failover_conf.get_primary) do
                @base.clean_exit("Primary server (#{@failover_conf.get_primary[:host]}:#{@failover_conf.get_primary[:port]}) is back. " +
                                 "Performing clean exit to be relaunched with primary config.")
              end
            end
            
            @base.settings = new_settings
            @base.reconnect
          else
            raise Error, "Could not connect to server #{@base.settings[:host]}:#{@base.settings[:port]}"
          end
        end
        
      end # OnDisconnect
    end # BasicClient
  end # Failover
end # AMQP

