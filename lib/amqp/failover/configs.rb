# encoding: utf-8

module AMQP
  class Failover
    class Configs < Array
      
      def initialize(confs = nil)
        load(confs)
      end
      
      def [](*args)
        return super(*args) if args[0].is_a?(Fixnum)
        return get_primary if args[0] == :primary
        get(args[0])
      end
      
      def []=(*args)
        return super(*args) if args[0].is_a?(Fixnum)
        return set_primary(args.last, args[0]) if args[0] == :primary
        set(args.last, args[0])
      end
      
      def refs
        @refs ||= {}
      end
      
      def primary
        @primary ||= 0
      end
      
      def primary=(ref)
        @primary = ref
      end
      
      def get_primary
        get(primary) || default_config
      end
      
      def set_primary(conf = {})
        set(conf, primary)
      end
      
      def get(ref = nil)
        return self[ref] if ref.is_a?(Fixnum)
        self[refs[ref]] if refs[ref]
      end
      
      def set(conf = {}, ref = nil)
        conf = Config.new(default_config.merge(conf))
        self << conf if (index = self.index(conf)).nil?
        if ref
          refs[ref] = (index || self.index(conf))
        end
      end
      
      def find_next(conf = {})
        current = self.index(conf)
        self[(current+1 == self.size) ? 0 : current+1] if current
      end
      
      def load_file(file, env = nil)
        raise ArgumentError, "Can't find #{file}" unless File.exists?(file)
        load(YAML.load_file(file)[env || "development"])
      end
      
      def load_yaml(data, env = nil)
        load(YAML.load(data)[env || "development"])
      end
      
      def load(conf)
        if conf.is_a?(::Array)
          load_array(conf)
        elsif conf.is_a?(::Hash)
          load_hash(conf)
        end
      end
      
      def self.load_array(confs = [])
        self.clear
        confs.each do |conf|
          conf = AMQP::Client.parse_amqp_url(conf) if conf.is_a?(::String)
          load_hash(conf)
        end
      end
      
      def load_hash(conf = {})
        set(Config.new(conf))
      end
      
      def default_config
        AMQP.settings
      end
      
    end # Config
  end # Failover
end # AMQP
