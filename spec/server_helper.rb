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
