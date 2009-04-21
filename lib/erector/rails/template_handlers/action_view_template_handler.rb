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

        is_partial = relative_path_parts.last =~ /^_/
        require_dependency File.expand_path(template.filename)

        widget_class_parts = relative_path_parts.inject(['Views']) do |class_parts, node|
          class_parts << node.gsub(/^_/, "").gsub(/(\.html)?\.rb$/, '').camelize
          class_parts
        end
        widget_class_name = widget_class_parts.join("::")
        render_method = is_partial ? 'render_partial' : 'content'

        erb_template = <<-ERB
        <%
          assigns = instance_variables.inject({}) do |hash, name|
            hash[name.sub('@', "")] = instance_variable_get(name)
            hash
          end

          widget = #{widget_class_name}.new(assigns)
          widget.to_s(:output => output_buffer, :helpers => self, :content_method_name => :#{render_method})
        %>
        ERB
        ::ERB.new(
          erb_template,
          nil,
          ::ActionView::TemplateHandlers::ERB.erb_trim_mode,
          "@output_buffer"
        ).src
      end
    end
  end
end
