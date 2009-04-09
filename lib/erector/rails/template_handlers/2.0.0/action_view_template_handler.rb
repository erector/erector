module ActionView #:nodoc:
  module TemplateHandlers #:nodoc:
    class Erector < TemplateHandler
      def self.line_offset
        2
      end

      attr_reader :view
      def initialize(view)
        @view = view
      end

      def compilable?
        true
      end
      undef :compile

      ActionView::Base.register_template_handler :rb, ActionView::TemplateHandlers::Erector

      def render(template, local_assigns)
        relative_path_parts = view.first_render.split('/')
        file_name = relative_path_parts.last
        require_dependency(view.template_file_path)

        dot_rb = /\.rb$/
        widget_class = relative_path_parts.inject(Views) do |mod, node|
          mod.const_get(node.gsub(dot_rb, '').gsub(".html", "").camelize)
        end
        render_method = view.is_partial_template? ? 'render_partial' : 'render'
        widget = widget_class.new(view, view.assigns)
        widget.to_s(render_method)
      end
    end
  end
end

