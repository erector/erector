module ActionView #:nodoc:
  module TemplateHandlers #:nodoc:
    class Erector
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

      ActionView::Base.register_template_handler :rb, ActionView::TemplateHandlers::Erector

      def render(template, local_assigns)
        relative_path_parts = view.first_render.split('/')
        require_dependency view.template_file_path

        dot_rb = /\.rb$/
        widget_class = relative_path_parts.inject(Views) do |mod, node|
          mod.const_get(node.gsub(dot_rb, '').gsub(".html", "").camelize)
        end
        render_method = view.is_partial_template? ? 'render_partial' : 'render'
        widget_class.new(view, view.assigns).to_s(render_method)
      end
    end
  end
end
