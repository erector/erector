require 'singleton'

module Erector
  class Cache
    include Singleton

    def []=(*args)
      value = args.pop
      ::Rails.cache.write(transform_key(args), value.to_s)
    end

    def [](*args)
      ::Rails.cache.read(transform_key(args))
    end

    def delete(*args)
      ::Rails.cache.delete(transform_key(args))
    end

    def transform_key(args)
      ActiveSupport::Cache.expand_cache_key(args.reject { |x| x.nil? }, 'erector')
    end

  end
end
