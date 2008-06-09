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

      def compile(template)
        relative_path_parts = view.first_render.split('/')
        require_dependency view.template_file_path

        dot_rb = /\.rb$/
        widget_class_parts = relative_path_parts.inject(['Views']) do |class_parts, node|
          class_parts << node.gsub(dot_rb, '').camelize
          class_parts
        end
        widget_class_name = widget_class_parts.join("::")
        render_method = view.is_partial_template? ? 'render_partial' : 'render'

        erector_template = "<% #{widget_class_name}.new(self, assigns, StringIO.new(_erbout)).#{render_method} %>"
        ::ERB.new(erector_template, nil, @view.erb_trim_mode).src
      end
    end
  end
end

ActionView::Base.instance_eval do
  if respond_to?(:register_template_handler)
    register_template_handler :rb, ActionView::TemplateHandlers::Erector
  end
end
