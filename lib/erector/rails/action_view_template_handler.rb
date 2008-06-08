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

        dot_rb = /\.rb$/
        widget_class_parts = paths.inject(['Views']) do |class_parts, node|
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
