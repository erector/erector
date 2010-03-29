module Erector
  class Cache
    def self.is_supported?
      RUBY_VERSION >= "1.8.7"
    end

    def initialize
      unless self.class.is_supported?
        raise Errors::RubyVersionNotSupported.new("< 1.8.7", "Erector::Cache uses Hashes with Hashes as keys.")
      end
      @stores = {}
    end

    def store_for(klass)
      @stores[klass] ||= {}
    end

    def []=(*args)
      value = args.pop
      klass = args.shift
      params = args.first || {}
      store_for(klass)[params] = value
    end

    def [](klass, params = {})
      store_for(klass)[params]
    end

    def delete(klass, params = {})
      store_for(klass).delete(params)
    end

    def delete_all(klass)
      @stores.delete(klass)
    end
  end
end
