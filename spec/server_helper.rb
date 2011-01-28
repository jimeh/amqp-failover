# encoding: utf-8

module ServerHelper
  include AMQP::Server
  
  class << self
    def log
      @@log ||= []
    end
    attr_writer :log
  end
  
  # log & silence STDOUT output
  def log(*args)
    @@log << args
  end
  
end


#
# Helper methods
#

def start_server(port = 15762, timeout = 2)
  bef_fork = EM.forks.clone
  EM.fork {
    EM.start_server('localhost', port, ServerHelper)
    EM.add_timer(timeout) { EM.stop }
  }
  (EM.forks - bef_fork).first
end

def stop_server(pid)
  Process.kill('TERM', pid)
end