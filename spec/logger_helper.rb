# encoding: utf-8

class LoggerHelper
  
  attr_accessor :error_log
  attr_accessor :info_log
  
  def info(*args)
    @info_log ||= []
    @info_log << args
  end
  
  def error(*args)
    @error_log ||= []
    @error_log << args
  end
  
end
