# encoding: utf-8

module ServerHelper
  include AMQP::Server
  
  class << self
    def log
      @@log ||= []
    end
    attr_writer :log
  end
  
  def log(*args)
    @@log << args
    # silence Output
  end
  
end
