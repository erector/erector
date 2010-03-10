module Erector
  class RailsFormBuilder
    attr_reader :parent, :template

    def initialize(object_name, object, template, options, proc)
      @template = template
      @parent = ActionView::Base.default_form_builder.new(object_name, object, template, options, proc)
    end

    def method_missing(method_name, *args, &block)
      if method_name.to_s =~ /!$/ && parent.respond_to?(method_name.to_s.gsub(/!$/, ""))
        return_value = parent.send(method_name.to_s.gsub(/!$/, ""), *args, &block)
        template.concat(return_value) if return_value.is_a?(String)
        return_value
      elsif parent.respond_to?(method_name)
        parent.send(method_name, *args, &block)
      else
        super
      end
    end

    [:fields_for, :form_for].each do |disallow_bang_method_base_name|
      define_method "#{disallow_bang_method_base_name}!" do |*args|
        raise "#{disallow_bang_method_base_name}! is not allowed. Only #{disallow_bang_method_base_name} is allowed."
      end
    end
  end
end