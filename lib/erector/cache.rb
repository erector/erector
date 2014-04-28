require 'singleton'

module Erector
  class Cache
    CACHE_NAMESPACE = 'erector'
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
      key = args.reject { |x| x.nil? }

      # If we're on Rails 3, coerce cache keys to array.
      # See changes to the retrieve_cache_key method here:
      # http://apidock.com/rails/v4.0.2/ActiveSupport/Cache/retrieve_cache_key/class
      if Gem::Version.new(::Rails.version) < Gem::Version.new('4.0.0')
        key = key.map do |x|
          if !x.respond_to?(:cache_key) && !x.is_a?(Array) && x.respond_to?(:to_a)
            x.to_a
          else
            x
          end
        end
      end

      ActiveSupport::Cache.expand_cache_key(key, CACHE_NAMESPACE)
    end

  end
end
