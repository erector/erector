module Erector
  module Rails
    class FormBuilder
      class_attribute :parent_builder_class
      self.parent_builder_class = ActionView::Base.default_form_builder

      def self.wrapping(parent_builder_class)
        return self if parent_builder_class.nil?
        Class.new(self).tap do |klass|
          klass.parent_builder_class = parent_builder_class
        end
      end

      attr_reader :parent, :template

      def initialize(object_name, object, template, options, proc)
        @template = template
        @parent = parent_builder_class.new(object_name, object, template, options, proc)
      end

      def method_missing(method_name, *args, &block)
        if parent.respond_to?(method_name)
          return_value = parent.send(method_name, *args, &block)
          if return_value.is_a?(String)
            template.concat(return_value)
            nil
          else
            return_value
          end
        else
          super
        end
      end
    end
  end
end
