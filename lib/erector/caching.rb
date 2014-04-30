module Erector
  module Caching
    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods
      def cacheable(value = true, opts = {})
        @cachable, @cache_opts = value, opts

        if value && value != true
          @cache_version = value
        end
      end

      alias_method :cachable, :cacheable

      def cachable?
        if @cachable.nil?
          superclass.respond_to?(:cachable?) && superclass.cachable?
        else
          @cachable
        end
      end

      def cache_opts
        if cachable?
          @cache_opts || {}
        end
      end

      def cache_version
        @cache_version || nil
      end

      def cache
        Erector::Cache.instance
      end
    end

    def cache
      self.class.cache
    end

    def should_cache?
      if block.nil? && self.class.cachable? && caching_configured?
        true
      else
        false
      end
    end

    def caching_configured?
      return true if !defined?(Rails)
      ::Rails.configuration.action_controller.perform_caching &&
      ::Rails.configuration.action_controller.cache_store
    end

    def cache_key_assigns
      if self.class.cache_opts[:only_keys]
        assigns.slice(*self.class.cache_opts[:only_keys])
      else
        assigns
      end
    end

    protected
    def _emit(options = {})
      if should_cache?
        cache[self.class, self.class.cache_version, cache_key_assigns, options[:content_method_name]] ||= super
      else
        super
      end
    end

    def _emit_via(parent, options = {})
      if should_cache?
        parent.output << cache[self.class, self.class.cache_version, cache_key_assigns, options[:content_method_name]] ||= parent.capture_content { super }
        parent.output.widgets << self.class # todo: test!!!
      else
        super
      end
    end
  end
end
