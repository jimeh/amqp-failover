# encoding: utf-8

module AMQP
  module Failover
    class Config
      
      attr_accessor :configs
      attr_accessor :failover_config
      
      def failover_config
        @failover_config ||= { :retry_timeout => 30 }
      end
      
      def refs
        @refs ||= {}
      end
      
      def configs
        @configs ||= []
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
        return configs[ref] if ref.is_a?(Fixnum)
        configs[refs[ref]] if refs[ref]
      end
      
      def set(conf = {}, ref = nil)
        conf = default_config.merge(conf)
        configs << conf if (index = configs.index(conf)).nil?
        if ref
          refs[ref] = (index || configs.index(conf))
        end
      end
      
      def find_next(conf = {})
        current = configs.index(conf)
        configs[(current+1 == configs.size) ? 0 : current+1] if current
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
      
      def load_array(confs = [])
        @configs = nil
        confs.each do |conf|
          load_hash(conf)
        end
      end
      
      def load_hash(conf = {})
        conf = conf.inject({}) do |result, (key, value)|
          result[key.is_a?(String) ? key.to_sym : key] = value
          result
        end
        self.set(conf)
      end
      
      def default_config
        AMQP.settings
      end
      
    end # Config
  end # Failover
end # AMQP
