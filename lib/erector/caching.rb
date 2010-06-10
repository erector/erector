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
      @stores[klass] ||= Hash.new {|h,k| h[k] = {}}
    end

    def []=(*args)
      value = args.pop
      klass = args.shift
      params = args.first.is_a?(Hash) ? args.first : {}
      content_method = args.last.is_a?(Symbol) ? args.last : :content
      store_for(klass)[params][content_method] = value
    end

    def [](klass, params = {}, content_method = :content)
      store_for(klass)[params][content_method]
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

    def _render_content_method(content_method)
      if should_cache?
        if cached = cache[self.class, @assigns, content_method]
          output << cached
        else
          output << cache[self.class, @assigns, content_method] = capture { super }
        end
      else
        super
      end
    end
  end
end
