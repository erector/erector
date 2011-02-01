require "erector/rails/railtie"
require "erector/rails/template_handler"
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
                                       :output  => Output.new { view.output_buffer }))
        end
      end

      # Wrappers for rails helpers that produce markup. Erector needs to
      # manually emit their result.
      def def_simple_rails_helper(method_name)
        module_eval <<-METHOD_DEF, __FILE__, __LINE__+1
          def #{method_name}(*args, &block)
            text helpers.#{method_name}(*args, &block)
          end
        METHOD_DEF
      end

      def def_rails_form_helper(method_name)
        module_eval <<-METHOD_DEF, __FILE__, __LINE__+1
          def #{method_name}(*args, &block)
            options = args.extract_options!
            args << options.merge(:builder => FormBuilder.wrapping(options[:builder]))
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

    def render(*args, &block)
      captured = helpers.capture do
        helpers.concat(helpers.render(*args, &block))
        helpers.output_buffer.to_s
      end
      rawtext(captured)
    end

    # Delegate to non-markup producing helpers via method_missing,
    # returning their result directly.
    def method_missing(name, *args, &block)
      if helpers.respond_to?(name)
        helpers.send(name, *args, &block)
      else
        super
      end
    end

    # Since we delegate method_missing to helpers, we need to delegate
    # respond_to? as well.
    def respond_to?(name)
      super || helpers.respond_to?(name)
    end

    [
      # UrlHelper
      :link_to,
      :button_to,
      :link_to_unless_current,
      :link_to_unless,
      :link_to_if,
      :mail_to,

      # FormTagHelper
      :form_tag,
      :select_tag,
      :text_field_tag,
      :label_tag,
      :hidden_field_tag,
      :file_field_tag,
      :password_field_tag,
      :text_area_tag,
      :check_box_tag,
      :radio_button_tag,
      :submit_tag,
      :image_submit_tag,
      :field_set_tag,

      # FormHelper
      :form_for,
      :text_field,
      :password_field,
      :hidden_field,
      :file_field,
      :text_area,
      :check_box,
      :radio_button,

      # AssetTagHelper
      :auto_discovery_link_tag,
      :javascript_include_tag,
      :stylesheet_link_tag,
      :image_tag,

      # ScriptaculousHelper
      :sortable_element,
      :sortable_element_js,
      :text_field_with_auto_complete,
      :draggable_element,
      :drop_receiving_element,

      # PrototypeHelper
      :link_to_remote,
      :button_to_remote,
      :periodically_call_remote,
      :form_remote_tag,
      :submit_to_remote,
      :update_page_tag,

      # JavaScriptHelper
      :javascript_tag,

      # CsrfHelper
      :csrf_meta_tag
    ].each do |method_name|
      def_simple_rails_helper(method_name)
    end

    [:form_for, :fields_for].each do |method_name|
      def_rails_form_helper(method_name)
    end

    Erector::Widget.send :include, self
  end
end
