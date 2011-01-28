# encoding: utf-8

module AMQP
  module Client
    class << self
      alias :connect_without_failover :connect
      
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
      #   - :fallback, monitor for original server's return and fallback to it if so.
      #   - :fallback_interval, seconds between each check for original server if :fallback is true.
      # 
      def connect_with_failover(opts = nil)
        opts = parse_amqp_url_or_opts(opts)
        connect_without_failover(opts)
      end
      alias :connect :connect_with_failover
      
      def parse_amqp_url_or_opts(opts = nil)
        if opts.is_a?(String) && opts.index(',').nil?
          opts = init_failover(opts.split(','))
        elsif opts.is_a?(Array)
          opts = init_failover(opts)
        elsif opts.is_a?(Hash) && opts[:hosts].is_a?(Array)
          confs = opts.delete[:hosts]
          opts = init_failover(confs, opts)
        end
        opts
      end
      
      def init_failover(confs = nil, opts = {})
        if !confs.nil? && confs.size > 0
          failover.primary.merge({ :failover => Failover.new(confs, opts) })
        end
      end
    
    end # << self
  end # Client
end # AMQP