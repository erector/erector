module ActionView #:nodoc:
  module TemplateHandlers #:nodoc:
    class RbHandler < TemplateHandler

      ActionView::Template.instance_eval do
        register_template_handler :rb, ActionView::TemplateHandlers::RbHandler
      end

      def render(template, local_assigns)
        relative_path_parts = template.path.split('/')

        is_partial = relative_path_parts.last =~ /^_/
        require_dependency File.expand_path(template.filename)

        widget_class_parts = relative_path_parts.inject(['Views']) do |class_parts, node|
          class_parts << node.gsub(/^_/, "").gsub(/(\.html)?\.rb$/, '').camelize
          class_parts
        end
        widget_class_name = widget_class_parts.join("::")
        render_method = is_partial ? :render_partial : :content

        assigns = @view.instance_variables.inject({}) do |hash, name|
          hash[name.sub('@', "")] = @view.instance_variable_get(name)
          hash
        end

        widget = widget_class_name.constantize.new(assigns)

        @view.with_output_buffer do
          widget.to_s(:output => @view.output_buffer,
                      :helpers => @view,
                      :content_method_name => render_method)
        end
      end
    end
  end
end
