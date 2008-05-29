module ActionView #:nodoc:
  module TemplateHandlers #:nodoc:
    class Erector
      def initialize(view)
        @view = view
      end

      def render(template, local_assigns)

        if template =~ /class ([\w:_]+)/
          classname_from_template = $1
          template_path = Inflector::underscore(classname_from_template)
        else
          template_path = @view.first_render
        end

        paths = template_path.split('/')
        if paths.first == 'views'
          paths.shift
          template_path = paths.join('/')
        end

        found = false
        @view.view_paths.each_with_index do |view_path, i|
          full_path = "#{view_path}/#{template_path}.rb"
          if File.exists?(full_path)
            require_dependency full_path
            found = true
            break
          else
            partial_file_path = full_path.gsub(/\/([^\/]*)$/, '/_\1')
            if File.exists?(partial_file_path)
              require_dependency partial_file_path
              found = true
              break
            end
          end
        end
        return unless found

        dot_rb = /\.rb$/
        widget_class = paths.inject(Views) do |current_module, node|
          current_module.const_get(node.gsub(dot_rb, '').camelize)
        end

        rendered_widget = widget_class.new(@view, @view.assigns)
        assign_locals(rendered_widget, local_assigns)
        rendered_widget.to_s
      end
      
    private
      # TODO: move into widget
      def assign_locals(widget, local_assigns)
        widget.assign_locals(local_assigns)
      end
      
    end
  end
end

ActionView::Base.instance_eval do
  if respond_to?(:register_template_handler)
    register_template_handler :rb, ActionView::TemplateHandlers::Erector
  end
end
# ActionMailer::Base.register_template_extension('rb')
