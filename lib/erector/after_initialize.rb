module Erector
  module AfterInitialize
    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods
      def after_initialize(&blk)
        after_initialize_parts << blk
      end

      def call_after_initialize(instance)
        if instance
          if superclass.respond_to?(:after_initialize)
            superclass.call_after_initialize instance
          end
          after_initialize_parts.each do |part|
            instance.instance_eval &part
          end
        end
      end

      protected
      def after_initialize_parts
        @after_initialize_parts ||= []
      end
    end
  end
end
