module Erector
  module Rails
    def self.assigns_for(widget_class, view, local_assigns, is_partial)
      assigns = {}
      
      instance_variables = view.instance_variables_for_widget_assignment
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
    
    def self.render(widget, controller, assigns = nil, options = {})
      view = controller.response.template
      
      if widget.is_a?(Class)
        assigns ||= assigns_for(widget, view, nil, false)
        widget = widget.new(assigns)
      end

      view.send(:_evaluate_assigns_and_ivars)

      widget.to_s({:helpers => view}.merge(options))
    end

    module WidgetExtensions
      module ClassMethods
        def ignore_extra_controller_assigns
          out = @ignore_extra_controller_assigns
          out ||= (superclass.ignore_extra_controller_assigns ? :true : :false) if superclass.respond_to?(:ignore_extra_controller_assigns)
          out ||= :true
          out == :true
        end

        # Often, large Rails applications will assign many controller instance variables.
        # Sometimes these aren't used by a view: ApplicationController might assign
        # variables that are used by many, but not all, views; and various other things
        # may accumulate, especially if you've been using templating systems that are
        # more forgiving than Erector. If you then migrate to Erector, you're stuck using
        # no "needs" declaration at all, because it needs to contain every assigned
        # variable, or Erector will raise an exception.
        #
        # If you set this to true (and it's inherited through to subclasses), however,
        # then "needs" declarations on the widget will cause excess controller variables
        # to be ignored -- they'll be unavailable to the widget (so 'needs' still means
        # something), but they won't cause widget instantiation to fail, either. This
        # can let a large Rails project transition to Erector more smoothly.
        def ignore_extra_controller_assigns=(new_value)
          @ignore_extra_controller_assigns = (new_value ? :true : :false)
        end

        def controller_assigns_propagate_to_partials
          out = @controller_assigns_propagate_to_partials
          out ||= (superclass.controller_assigns_propagate_to_partials ? :true : :false) if superclass.respond_to?(:controller_assigns_propagate_to_partials)
          out ||= :true
          out == :true
        end

        # In ERb templates, controller instance variables are available to any partial
        # that gets rendered by the view, no matter how deeply-nested. This effectively
        # makes controller instance variables "globals". In small view hierarchies this
        # probably isn't an issue, but in large ones it can make debugging and
        # reasoning about the code very difficult.
        #
        # If you set this to true (and it's inherited through to subclasses), then any
        # widget that's getting rendered as a partial will only have access to locals
        # explicitly passed to it (render :partial => ..., :locals => ...). (This
        # doesn't change the behavior of widgets that are explicitly rendered, as they
        # don't have this issue.) This can allow for cleaner encapsulation of partials,
        # as they must be passed everything they use and can't rely on controller
        # instance variables.
        def controller_assigns_propagate_to_partials=(new_value)
          @controller_assigns_propagate_to_partials = (new_value ? :true : :false)
        end
      end
      
      def self.included(base)
        base.extend(ClassMethods)
      end

      # When we set up the erector output, we need to make sure that
      # Rails gets the same output buffer, via helpers.with_output_buffer.
      def context(parent, output, helpers = nil, &blk)
        if helpers.respond_to?(:with_output_buffer)
          helpers.with_output_buffer(output) do
            super
          end
        else
          super
        end
      end

      # We need to delegate #output to helpers.output_buffer, so that
      # when Rails's #capture/#with_output_buffer executes a block,
      # erector output done by the block goes to the appropriate output
      # buffer (i.e., the one set up by our ActionView#with_output_buffer
      # patch).
      def output
        if helpers.respond_to?(:output_buffer)
          helpers.output_buffer
        else
          super
        end
      end

      # We need to delegate #capture to helpers.capture, so that when
      # the captured block is executed, any rails output done by the block
      # goes to the appropriate output buffer (i.e., the one set up by our
      # ActionView#with_output_buffer patch).
      def capture(&block)
        if helpers.respond_to?(:capture)
          raw(helpers.capture(&block).to_s)
        else
          super
        end
      end

      def method_missing(name, *args, &block)
        if helpers.respond_to?(name)
          helpers.send(name, *args, &block)
        else
          super
        end
      end

      # This is here to force #helpers.capture to return the output
      def __in_erb_template;
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
