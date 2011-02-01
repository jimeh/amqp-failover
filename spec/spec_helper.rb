# encoding: utf-8

# add project-relative load paths
$LOAD_PATH.unshift File.expand_path(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift File.expand_path(File.dirname(__FILE__))

# require stuff
require 'rubygems'

begin
  require 'mq'
rescue LoadError => e
  require 'amqp'
end
require 'amqp/failover'

require 'rspec'
require 'rspec/autorun'


#
# Helper methods
#

def wait_while(timeout = 10, retry_interval = 0.1, &block)
  start = Time.now
  while block.call
    break if (Time.now - start).to_i >= timeout
    sleep(retry_interval)
  end
end

# stolen from Pid::running? from daemons gem
def pid_running?(pid)
  return false unless pid
  
  # Check if process is in existence
  # The simplest way to do this is to send signal '0'
  # (which is a single system call) that doesn't actually
  # send a signal
  begin
    Process.kill(0, pid)
    return true
  rescue Errno::ESRCH
    return false
  rescue ::Exception   # for example on EPERM (process exists but does not belong to us)
    return true
  end
end
