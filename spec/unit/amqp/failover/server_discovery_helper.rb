class ServerDiscoveryHelper < AMQP::Failover::ServerDiscovery
  
  class << self
    alias :real_start_monitoring :start_monitoring
    def start_monitoring(*args, &block)
      $called << :start_monitoring
      real_start_monitoring(*args, &block)
    end
  end
  
  alias :real_initialize :initialize
  def initialize(*args)
    $called << :initialize
    EM.start_server('127.0.0.1', 9999) if $start_count == 2
    $start_count += 1
    real_initialize(*args)
  end
  
  alias :real_connection_completed :connection_completed
  def connection_completed
    $called << :connection_completed
    real_connection_completed
  end
  
  alias :real_close_connection :close_connection
  def close_connection
    $called << :close_connection
    real_close_connection
  end
  
end