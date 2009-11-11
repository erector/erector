module Erector
  module Rails
    # These controller instance variables should not be passed to the
    # widget if it does not +need+ them.
    NON_NEEDED_CONTROLLER_INSTANCE_VARIABLES = [:@template, :@_request]
    
    def self.render(widget, controller, assigns = nil)
      if widget.is_a?(Class)
        unless assigns
          needs = widget.get_needed_variables
          assigns = {}
          variables = controller.instance_variable_names
          variables -= controller.protected_instance_variables
          variables.each do |name|
            assign = name.sub('@', '').to_sym
            next if !needs.empty? && !needs.include?(assign) && NON_NEEDED_CONTROLLER_INSTANCE_VARIABLES.include?(name.to_sym)
            assigns[assign] = controller.instance_variable_get(name)
          end
        end

        widget = widget.new(assigns)
      end

      view = controller.response.template
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
