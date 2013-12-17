module Erector
  module Caching
    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods
      def cacheable(value = true)
        @cachable = value
      end

      alias_method :cachable, :cacheable

      def cachable?
        if @cachable.nil?
          superclass.respond_to?(:cachable?) && superclass.cachable?
        else
          @cachable
        end
      end

      def cache
        Erector::Cache.instance
      end
    end

    def cache
      self.class.cache
    end

    def should_cache?
      if block.nil? && self.class.cachable?
        true
      else
        false
      end
    end

    protected
    def _emit(options = {})
      if should_cache?
        cache[self.class, assigns, options[:content_method_name]] ||= super
      else
        super
      end
    end

    def _emit_via(parent, options = {})
      if should_cache?
        parent.output << cache[self.class, assigns, options[:content_method_name]] ||= parent.capture_content { super }
        parent.output.widgets << self.class # todo: test!!!
      else
        super
      end
    end
  end
end
