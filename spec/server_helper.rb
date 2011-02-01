# encoding: utf-8

require 'rubygems'
require 'mq'
require 'amqp'
require 'amqp/server'
require 'json'

class ServerHelper
  
  attr_accessor :stdin
  attr_accessor :stdout
  attr_accessor :stderr
  attr_accessor :pid
  
  
  def initialize(port = nil, timeout = nil)
    @port = port
    @timout = timeout
    File.open(log_file, 'w') {}
    @pid = start(port, timeout)
  end
  
  def self.clear_logs
    Dir.glob(File.expand_path('server_helper*.log', File.dirname(__FILE__))).each do |file|
      File.delete(file)
    end
  end
  
  def start(port = nil, timeout = nil)
    port ||= 15672
    timeout ||= 2
    EM.fork_reactor {
      $PORT = port
      EM.start_server('localhost', port, AmqpServer)
      EM.add_timer(timeout) { EM.stop }
    }
  end
  
  def stop
    Process.kill('TERM', @pid)
  end
  
  def kill
    Process.kill('KILL', @pid)
  end
  
  def log
    File.open(log_file).to_a.map{ |l| JSON.parse(l) }
  end
  
  def log_file
    File.expand_path("server_helper-port#{@port}.log", File.dirname(__FILE__))
  end
  
end

module AmqpServer
  include AMQP::Server

  # customize log output
  def log(*args)
    args = {:method => args[0], :class => args[1].payload.class, :pid => Process.pid}
    filename = File.expand_path("server_helper-port#{$PORT}.log", File.dirname(__FILE__))
    File.open(filename, 'a') do |f|
      f.write("#{args.to_json}\n")
    end
  end
end

#
# Helper methods
#

def start_server(port = nil, timeout = nil)
  ServerHelper.new(port, timeout)
end
