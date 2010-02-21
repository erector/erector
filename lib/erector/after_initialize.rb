module Erector
  module AfterInitialize
    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods
      def after_initialize(instance=nil, &blk)
        if blk
          after_initialize_parts << blk
        elsif instance
          if superclass.respond_to?(:after_initialize)
            superclass.after_initialize instance
          end
          after_initialize_parts.each do |part|
            instance.instance_eval &part
          end
        else
          raise ArgumentError, "You must provide either an instance or a block"
        end
      end

      protected
      def after_initialize_parts
        @after_initialize_parts ||= []
      end
    end

    def initialize(*args, &blk)
      super
      self.class.after_initialize self
    end
  end
end
