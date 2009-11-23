module Erector
  module Rails
    # These controller instance variables should not be passed to the
    # widget if it does not +need+ them.
    NON_NEEDED_CONTROLLER_INSTANCE_VARIABLES = [:template, :_request]
    
    def self.assigns_for(widget_class, view, local_assigns, is_partial)
      assigns = {}
      
      instance_variables = instance_variable_assigns(widget_class, view)
      if is_partial || widget_class.ignore_extra_controller_assigns
        instance_variables = remove_unneeded_assigns(widget_class, instance_variables)
      end

      assigns.merge!(instance_variables) unless is_partial && (! widget_class.controller_assigns_propagate_to_partials)
      
      if is_partial
        assigns.merge!(filter_local_assigns_for_partial(widget_class, local_assigns || { }))
      end
      
      assigns
    end
    
    def self.remove_unneeded_assigns(widget_class, assigns)
      needs = widget_class.get_needed_variables
      if needs.empty?
        assigns
      else
        assigns.reject { |key, value| ! needs.include?(key) }
      end
    end
    
    def self.filter_local_assigns_for_partial(widget_class, local_assigns)
      widget_class_variable_name = widget_class.name.underscore
      widget_class_variable_name = $1 if widget_class_variable_name =~ %r{.*/(.*?)$}
      
      local_assigns.reject do |name, value|
        name == :object || name == widget_class_variable_name.to_sym
      end
    end
    
    def self.instance_variable_assigns(widget_class, view)
      needs = widget_class.get_needed_variables
      assigns = view.instance_variables_for_widget_assignment
      assigns.delete_if do |name, value|
        !needs.empty? && !needs.include?(name) && NON_NEEDED_CONTROLLER_INSTANCE_VARIABLES.include?(name.to_sym)
      end
      assigns
    end
    
    def self.render(widget, controller, assigns = nil)
      view = controller.response.template
      
      if widget.is_a?(Class)
        assigns ||= assigns_for(widget, view, nil, false)
        widget = widget.new(assigns)
      end

      view.send(:_evaluate_assigns_and_ivars)

      view.with_output_buffer do
        widget.to_s(
          :output => view.output_buffer,
          :parent => view,
          :helpers => view
        )
      end
    end

    module WidgetExtensions
      def self.included(base)
        base.alias_method_chain :output, :parent
        base.alias_method_chain :capture, :parent
      end

      def output_with_parent
        if parent.respond_to?(:output_buffer)
          parent.output_buffer.is_a?(String) ? parent.output_buffer : handle_rjs_buffer
        else
          output_without_parent
        end
      end

      def capture_with_parent(&block)
        parent ? raw(parent.capture(&block).to_s) : capture_without_parent(&block)
      end

      # This is here to force #parent.capture to return the output
      def __in_erb_template;
      end

      private

      def handle_rjs_buffer
        returning buffer = parent.output_buffer.dup.to_s do
          parent.output_buffer.clear
          parent.with_output_buffer(buffer) do
            buffer << parent.output_buffer.to_s
          end
        end
      end
    end

    Erector::Widget.send :include, WidgetExtensions
  end

  # RailsWidget and InlineRailsWidget are for backward compatibility.
  # New code should use Widget, InlineWidget, or Erector.inline.
  class RailsWidget < Widget
    def self.inline(*args, &block)
      InlineRailsWidget.new(*args, &block)
    end
  end

  class InlineRailsWidget < RailsWidget
    include Inline
  end
end
