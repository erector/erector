module ActionView
  module TemplateHandlers
    class Erector
      def initialize(view)
        @view = view
      end

      def render(template, assigns)
        paths = @view.first_render.split('/')
        dot_rb = /\.rb$/
        widget_class = paths.inject(Views) do |current_module, node|
          current_module.const_get(node.gsub(dot_rb, '').camelize)
        end

        rendered_widget = widget_class.new(@view, assigns)
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
