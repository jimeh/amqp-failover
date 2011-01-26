# encoding: utf-8

module AMQP
  module Failover
    class Logic
      class FailedConfig < ::Hash
        
        attr_accessor :last_fail
        
        def initialize(hash = {}, last_fail_date = nil)
          self.replace(hash)
          self.last_fail = last_fail_date if last_fail_date
        end
        
        # order by latest fail, potentially useful if random config selection is used
        def <=>(other)
          if self.respond_to?(:last_fail) && other.respond_to?(:last_fail)
            if self.last_fail.nil? && other.last_fail.nil?
              return 0
            elsif self.last_fail.nil? && !other.last_fail.nil?
              return 1
            elsif !self.last_fail.nil? && other.last_fail.nil?
              return -1
            end
            return other.last_fail <=> self.last_fail
          end
          return 0
        end
        
      end # FailedConfig
    end # Logic
  end # Failover
end # AMQP
