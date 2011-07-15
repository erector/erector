module Erector
  class RailsFormBuilder
    attr_reader :parent, :template

    def initialize(object_name, object, template, options, proc)
      @template = template
      @parent = ActionView::Base.default_form_builder.new(object_name, object, template, options, proc)
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
