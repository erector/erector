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
      cache && block.nil? && self.class.cachable?
    end

    def _render(options = {})
      if should_cache?
        cache[self.class, assigns, options[:content_method_name]] ||= super
      else
        super
      end
    end

    def _render_via(parent, options = {})
      if should_cache?
        parent.output << cache[self.class, assigns, options[:content_method_name]] ||= parent.capture { super }
        parent.output.widgets << self.class # todo: test!!!
      else
        super
      end
    end
  end
end
