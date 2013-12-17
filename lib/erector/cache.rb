module Erector
  class Cache
    def initialize
      @stores = {}
    end

    def store_for(klass)
      @stores[klass] ||= Hash.new {|h,k| h[k] = {}}
    end

    def []=(*args)
      value = args.pop
      klass = args.shift
      params = args.first.is_a?(Hash) ? args.first : {}
      content_method = args.last.is_a?(Symbol) ? args.last : nil
      store_for(klass)[key(params)][content_method] = value
    end

    def [](klass, params = {}, content_method = nil)
      store_for(klass)[key(params)][content_method]
    end

    def delete(klass, params = {})
      store_for(klass).delete(key(params))
    end

    def delete_all(klass)
      @stores.delete(klass)
    end

    # convert hash-key to array-key for compatibility with 1.8.6
    def key(params)
      params.to_a
    end
  end
end
