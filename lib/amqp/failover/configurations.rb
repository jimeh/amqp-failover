# encoding: utf-8

module AMQP
  class Failover
    class Configurations < Array
      
      def initialize(confs = nil)
        load(confs)
      end
      
      def [](*args)
        if args[0].is_a?(Symbol)
          return primary if args[0] == :primary
          get(args[0])
        else
          super(*args)
        end
      end
      
      def []=(*args)
        if args[0].is_a?(Symbol)
          return primary = args.last if args[0] == :primary
          set(args.last, args[0])
        end
        super(*args)
      end
      
      def refs
        @refs ||= {}
      end
      
      def primary_ref
        @primary_ref ||= 0
      end
      
      def primary_ref=(ref)
        @primary_ref = ref
      end
      
      def primary
        get(primary_ref) || AMQP.settings
      end
      
      def primary=(conf = {})
        set(conf, primary_ref)
      end
      
      def get(ref = nil)
        return self[ref] if ref.is_a?(Fixnum)
        self[refs[ref]] if refs[ref]
      end
      
      def set(conf = {}, ref = nil)
        conf = Failover::Config.new(conf) if !conf.is_a?(Failover::Config)
        if (index = self.index(conf)).nil?
          self << conf
        else
          conf = self[index]
        end
        refs[ref] = (index || self.index(conf)) if ref
        conf
      end
      
      def find_next(conf = {})
        current = self.index(conf)
        self[(current+1 == self.size) ? 0 : current+1] if current
      end
      
      def load(conf)
        if conf.is_a?(Array)
          load_array(conf)
        elsif conf.is_a?(Hash)
          load_hash(conf)
        end
      end
      
      def load_array(confs = [])
        self.clear
        refs = {}
        confs.each do |conf|
          conf = AMQP::Client.parse_amqp_url(conf) if conf.is_a?(String)
          load_hash(conf)
        end
      end
      
      def load_hash(conf = {})
        set(conf)
      end
      
    end # Config
  end # Failover
end # AMQP
