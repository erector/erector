module Erector
  module Rails
    def self.should_assign?(name, widget_class, is_partial)
      (!widget_class.ignore_extra_controller_assigns || widget_class.needs?(name)) &&
        (!is_partial || widget_class.controller_assigns_propagate_to_partials)
    end

    def self.assigns_for(widget_class, view, local_assigns, is_partial)
      assigns = {}

      view.assigns.each do |name, value|
        name = name.to_sym
        assigns[name] = value if should_assign?(name, widget_class, is_partial)
      end

      assigns.merge!(filter_local_assigns_for_partial(widget_class, local_assigns)) if is_partial

      assigns
    end

    def self.filter_local_assigns_for_partial(widget_class, local_assigns)
      widget_class_variable_name = widget_class.name.underscore
      widget_class_variable_name = $1 if widget_class_variable_name =~ %r{.*/(.*?)$}

      local_assigns.reject do |name, value|
        name == :object || name == widget_class_variable_name.to_sym
      end
    end

    def self.render(widget, view, local_assigns = {}, is_partial = false, options = {})
      widget = widget.new(assigns_for(widget, view, local_assigns, is_partial)) if widget.is_a?(Class)
      view.with_output_buffer do
        # Set parent to the view and use Rails's output buffer.
        widget.to_html(options.merge(:parent => view,
                                  :output => Output.new { view.output_buffer }))
      end
    end

    module WidgetExtensions
      extend ActiveSupport::Concern

      included do
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
        class_attribute :ignore_extra_controller_assigns
        self.ignore_extra_controller_assigns = true

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
        class_attribute :controller_assigns_propagate_to_partials
        self.controller_assigns_propagate_to_partials = true
      end

      # We need to delegate #capture to parent.capture, so that when
      # the captured block is executed, both erector and Rails output
      # from within the block go to the appropriate buffer.
      def capture(&block)
        if parent.respond_to?(:capture)
          raw(parent.capture(&block).to_s)
        else
          super
        end
      end
    end

    Erector::Widget.send :include, WidgetExtensions
  end
end
