module ActionView
  module TemplateHandlers
    class Erector
      def initialize(view)
        @view = view
      end

      def render(template, local_assigns)
        banana = @view.first_render
        paths = banana.split('/')
        dot_rb = /\.rb$/
        file_path = "#{RAILS_ROOT}/app/views/#{banana}.rb"
        if File.exists?(file_path)
          require_dependency file_path
        else
          partial_file_path = file_path.gsub(/\/([^\/]*)$/, '/_\1')
          if File.exists?(partial_file_path)
            require_dependency partial_file_path
          else
            return
          end
        end
        widget_class = paths.inject(Views) do |current_module, node|
          current_module.const_get(node.gsub(dot_rb, '').camelize)
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
