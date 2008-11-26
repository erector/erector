module ActionView #:nodoc:
  module TemplateHandlers #:nodoc:
    class Erector < TemplateHandler
      def self.line_offset
        2
      end

      attr_reader :view
      def initialize(*view)
        @view = view
      end

      def compilable?
        true
      end

      ActionView::Template.instance_eval do
        register_template_handler :rb, ActionView::TemplateHandlers::Erector
      end

      def compile_template(template)
        relative_path_parts = view.first_render.split('/')
        require_dependency view.finder.pick_template(
          template.path,
          view.finder.pick_template_extension(template.path)
        )

        dot_rb = /\.rb$/
        widget_class_parts = relative_path_parts.inject(['Views']) do |class_parts, node|
          class_parts << node.gsub(dot_rb, '').camelize
          class_parts
        end
        widget_class_name = widget_class_parts.join("::")
        render_method = template.is_a?(ActionView::PartialTemplate) ? 'render_partial' : 'render'

        erb_template = "<% #{widget_class_name}.new(self, controller.assigns, _erbout).#{render_method} %>"
        ::ERB.new(erb_template, nil, @view.erb_trim_mode).src
      end
      alias_method :compile, :compile_template

      def render(template)
        relative_path_parts = view.first_render.split('/')
        require_dependency view.finder.pick_template(
          template.path,
          view.finder.pick_template_extension(template.path)
        )

        dot_rb = /\.rb$/
        widget_class = relative_path_parts.inject(Views) do |mod, node|
          mod.const_get(node.gsub(dot_rb, '').camelize)
        end
        render_method = template.is_a?(ActionView::PartialTemplate) ? 'render_partial' : 'render'
        widget_class.new(view, view.assigns).to_s(render_method)
      end
    end
  end
end
