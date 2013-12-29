require "erector/rails/template_handler"
require "erector/rails/railtie"
require "erector/rails/widget_renderer"
require "erector/rails/form_builder"

module Erector
  module Rails
    class << self
      def should_assign?(name, widget_class, is_partial)
        (!widget_class.ignore_extra_controller_assigns || widget_class.needs?(name)) &&
          (!is_partial || widget_class.controller_assigns_propagate_to_partials)
      end

      def assigns_for(widget_class, view, local_assigns, is_partial)
        assigns = {}

        view.assigns.each do |name, value|
          name = name.to_sym
          assigns[name] = value if should_assign?(name, widget_class, is_partial)
        end

        assigns.merge!(filter_local_assigns_for_partial(widget_class, local_assigns)) if is_partial

        assigns
      end

      def filter_local_assigns_for_partial(widget_class, local_assigns)
        widget_class_variable_name = widget_class.name.underscore
        widget_class_variable_name = $1 if widget_class_variable_name =~ %r{.*/(.*?)$}

        local_assigns.reject do |name, value|
          name == :object || name == widget_class_variable_name.to_sym
        end
      end

      def render(widget, view, local_assigns = {}, is_partial = false, options = {})
        widget = widget.new(assigns_for(widget, view, local_assigns, is_partial)) if widget.is_a?(Class)
        view.with_output_buffer do
          # Set parent and helpers to the view and use Rails's output buffer.
          widget.to_html(options.merge(:helpers => view,
                                       :parent  => view,
                                       :output  => Output.new(:buffer => lambda { view.output_buffer })))
        end
      end

      def def_rails_form_helper(method_name, explicit_builder = nil)
        module_eval <<-METHOD_DEF, __FILE__, __LINE__+1
          def #{method_name}(*args, &block)
            options = args.extract_options!
            args << options.merge(:builder => FormBuilder.wrapping(#{explicit_builder || 'options[:builder]'}))
            text helpers.#{method_name}(*args, &block)
          end
        METHOD_DEF
      end
    end

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

    # We need to delegate #capture to helpers.capture, so that when
    # the captured block is executed, both erector and Rails output
    # from within the block go to the appropriate buffer.
    def capture(&block)
      if helpers.respond_to?(:capture)
        raw(helpers.capture(&block).to_s)
      else
        super
      end
    end

    # Wrap Rails' render method, to capture output from partials etc.
    def render(*args, &block)
      captured = helpers.capture do
        helpers.concat(helpers.render(*args, &block))
        helpers.output_buffer.to_s
      end
      rawtext(captured)
    end

    # Rails content_for is output if and only if no block given
    def content_for(*args,&block)
      if block
        helpers.content_for(*args,&block)
      else
        rawtext(helpers.content_for(*args))
        ''
      end
    end

    # Delegate to non-markup producing helpers via method_missing,
    # returning their result directly.
    def method_missing(name, *args, &block)
      if helpers.respond_to?(name)
        return_value = helpers.send(name, *args, &block)

        if return_value.try(:html_safe?)
          text return_value
        else
          return_value
        end
      else
        super
      end
    end

    # Since we delegate method_missing to helpers, we need to delegate
    # respond_to? as well.
    def respond_to?(name)
      super || helpers.respond_to?(name)
    end

    [:form_for, :fields_for].each do |method_name|
      def_rails_form_helper(method_name)
    end

    [:simple_form_for, :simple_fields_for].each do |method_name|
      def_rails_form_helper(method_name, "SimpleForm::FormBuilder")
    end

    Erector::Widget.send :include, self
  end
end
