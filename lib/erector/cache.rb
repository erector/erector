module Erector
  class Cache
    def initialize
      @stores = {}
    end

    def store_for(klass)
      @stores[klass] ||= Erector::RailsCache.new(klass)
    end

    def []=(*args)
      value = args.pop
      klass = args.shift
      params = args.first.is_a?(Hash) ? args.first : {}
      content_method = args.last.is_a?(Symbol) ? args.last : nil
      store_for(klass)[key(params, content_method)] = value
    end

    def [](klass, params = {}, content_method = nil)
      store_for(klass)[key(params, content_method)]
    end

    def delete(klass, params = {})
      store_for(klass).delete(key(params))
    end

    # convert hash-key to array-key for compatibility with 1.8.6
    def key(params, content_method = nil)
      params.to_a.push(content_method)
    end
  end

  class RailsCache
    def initialize(prefix)
      @prefix = prefix
    end

    def []=(key, val)
      ::Rails.cache.write(prefix(key), val.to_s)
    end

    def [](key)
      ::Rails.cache.read(prefix(key))
    end

    def delete(key)
      ::Rails.cache.delete(prefix(key))
    end

    def prefix(key)
      ['erector', @prefix, *key]
    end
  end

end
