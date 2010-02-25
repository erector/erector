module Erector
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
