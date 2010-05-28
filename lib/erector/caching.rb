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

  module Caching
    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods
      def cacheable(value = true)
        @cachable = value
      end

      def cachable(value = true)
        @cachable = value
      end

      def cachable?
        if @cachable.nil?
          superclass.respond_to?(:cachable?) && superclass.cachable?
        else
          @cachable
        end
      end

      def cache
        @@cache ||= nil
      end

      def cache=(c)
        @@cache = c
      end
    end

    def cache
      self.class.cache
    end

    def should_cache?
      cache && @block.nil? && self.class.cachable?
    end

    def _render_content_method(content_method, &blk)
      if should_cache?
        if (cached_string = cache[self.class, @assigns])
          output << cached_string
        else
          super
          cache[self.class, @assigns] = output.to_s
        end
      else
        super
      end
    end

    def _call_content
      if should_cache?
        cached_string = cache[self.class, @assigns]
        if cached_string.nil?
          cached_string = capture { super }
          cache[self.class, @assigns] = cached_string
        end
        rawtext cached_string
      else
        super
      end
    end
  end
end
