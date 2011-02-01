# encoding: utf-8

module AMQP
  class Failover
    class Config < ::Hash
      
      attr_accessor :last_fail
      
      def initialize(hash = {}, last_fail_date = nil)
        self.replace(symbolize_keys(defaults.merge(hash)))
        self.last_fail = last_fail_date if last_fail_date
      end
      
      def defaults
        AMQP.settings
      end
      
      def symbolize_keys(hash = {})
        hash.inject({}) do |result, (key, value)|
          result[key.is_a?(String) ? key.to_sym : key] = value
          result
        end
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
      
    end # Config
  end # Failover
end # AMQP
