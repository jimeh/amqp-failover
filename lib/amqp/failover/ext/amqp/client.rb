# encoding: utf-8

AMQP.client = AMQP::FailoverClient

module AMQP
  module Client
    
    class << self
      
      # Connect with Failover supports specifying multiple AMQP servers and configurations.
      # 
      # Argument Examples:
      #   - "amqp://guest:guest@host:5672,amqp://guest:guest@host:5673"
      #   - ["amqp://guest:guest@host:5672", "amqp://guest:guest@host:5673"]
      #   - [{:host => "host", :port => 5672}, {:host => "host", :port => 5673}]
      #   - {:hosts => ["amqp://user:pass@host:5672", "amqp://user:pass@host:5673"]}
      #   - {:hosts => [{:host => "host", :port => 5672}, {:host => "host", :port => 5673}]}
      #
      # The last two examples are by far the most flexible, cause they also let you specify
      # failover and fallback specific options. Like so:
      #   - {:hosts => ["amqp://localhost:5672"], :fallback => false}
      # 
      # Available failover options are:
      #   - :retry_timeout, time to wait before retrying a specific AMQP config after failure.
      #   - :primary_config, specify which of the supplied configurations is it the primary one. The default
      #                      value is 0, the first item in the config array. Use 1 for the second and so on.
      #   - :fallback, check for the return of the primary server, and fallback to it if and when it returns.
      #   - :fallback_interval, seconds between each check for original server if :fallback is true.
      #   - :selection, not yet implimented.
      # 
      def connect_with_failover(opts = nil)
        opts = parse_amqp_url_or_opts_with_failover(opts)
        connect_without_failover(opts)
      end
      alias :connect_without_failover :connect
      alias :connect :connect_with_failover
      
      def parse_amqp_url_or_opts_with_failover(opts = nil)
        if opts.is_a?(String) && opts.index(',').nil?
          opts = init_failover(opts.split(','))
        elsif opts.is_a?(Array)
          opts = init_failover(opts)
        elsif opts.is_a?(Hash) && opts[:hosts].is_a?(Array)
          confs = opts.delete(:hosts)
          opts = init_failover(confs, opts)
        end
        opts
      end
      
      def init_failover(confs = nil, opts = {})
        if !confs.nil? && confs.size > 0
          failover = Failover.new(confs, opts)
          failover.primary.merge({ :failover => failover })
        end
      end
      
    end # << self
    
    def initialize_with_failover(opts = {})
      @failover = opts.delete(:failover) if opts.has_key?(:failover)
      initialize_without_failover(opts)
    end
    alias :initialize_without_failover :initialize
    alias :initialize :initialize_with_failover
    
    def unbind_with_failover
      @on_disconnect = method(:failover_switch) if @failover
      unbind_without_failover
    end
    alias :unbind_without_failover :unbind
    alias :unbind :unbind_with_failover
    
  end # Client
end # AMQP