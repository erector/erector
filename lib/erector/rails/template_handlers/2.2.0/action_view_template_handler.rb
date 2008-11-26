module ActionView #:nodoc:
  module TemplateHandlers #:nodoc:
    class Erector < TemplateHandler
      include Compilable
      def self.line_offset
        2
      end

      ActionView::Template.instance_eval do
        register_template_handler :rb, ActionView::TemplateHandlers::Erector
      end

      def compile(template)
        relative_path_parts = template.path.split('/')

        require_dependency File.expand_path("#{RAILS_ROOT}/app/views/#{template.path}")

        widget_class_parts = relative_path_parts.inject(['Views']) do |class_parts, node|
          class_parts << node.gsub(/\.rb$/, '').camelize
          class_parts
        end
        widget_class_name = widget_class_parts.join("::")
        render_method = template.is_a?(ActionView::Partials) ? 'render_partial' : 'render'

        erb_template = "<% #{widget_class_name}.new(self, controller.assigns, StringIO.new(_erbout)).#{render_method} %>"
        ::ERB.new(erb_template, nil, ::ActionView::TemplateHandlers::ERB.erb_trim_mode).src
      end
    end
  end
end
