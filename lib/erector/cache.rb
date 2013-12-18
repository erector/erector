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
      ['erector'] + args.reject { |x| x.nil? }.map { |x|
        if x.is_a?(Hash)
          transformed = {}

          x.each do |k, v|
            transformed[k] = v.respond_to?(:cache_key) ? v.cache_key : v
          end

          transformed
        else
          x
        end
      }
    end

  end
end
