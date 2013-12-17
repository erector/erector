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
      ['erector'] + args.reject { |x| x.nil? }
    end

  end
end
