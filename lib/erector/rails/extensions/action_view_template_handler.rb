module ActionView #:nodoc:
  module TemplateHandlers #:nodoc:
    class Erector
      attr_reader :view
      def initialize(view)
        @view = view
      end

      def render(template, local_assigns)
        render_path = view.first_render
        paths = render_path.split('/')
        dot_rb = /\.rb$/
        file_path = "#{RAILS_ROOT}/app/views/#{render_path}.rb"
        if view.is_partial_template?
          partial_file_path = file_path.gsub(/\/([^\/]*)$/, '/_\1')
          require_dependency partial_file_path
        else
          require_dependency file_path
        end
        widget_module = paths[0..-1].inject(Views) do |current_module, node|
          current_module.const_get(node.gsub(dot_rb, '').camelize)
        end
        if view.is_partial_template?
          widget_class = widget_module.const_get("#{paths.last.gsub(dot_rb, '').camelize}Partial")
        else
          widget_class = widget_module.const_get(paths.last.gsub(dot_rb, '').camelize)
        end

        rendered_widget = widget_class.new(@view, @view.assigns)
        rendered_widget.to_s
      end
    end
  end
end

ActionView::Base.instance_eval do
  if respond_to?(:register_template_handler)
    register_template_handler :rb, ActionView::TemplateHandlers::Erector
  end
end
