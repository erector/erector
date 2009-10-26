module Erector
  class RailsWidget < Widget
    def self.inline(*args, &block)
      InlineRailsWidget.new(*args, &block)
    end

    def self.render(widget, controller, assigns = nil, is_partial = false)
      if widget.is_a?(Class)
        unless assigns
          assigns = {}
          variables = controller.instance_variable_names
          variables -= controller.protected_instance_variables
          variables.each do |name|
            assigns[name.sub('@', "").to_sym] = controller.instance_variable_get(name)
          end
        end

        widget = widget.new(assigns)
      end

      view = controller.response.template
      view.send(:_evaluate_assigns_and_ivars)

      view.with_output_buffer do
        widget.to_s(:output => view.output_buffer,
                    :parent => view,
                    :helpers => view,
                    :content_method_name => is_partial ? :render_partial : :content)
      end
    end

    def output
      process_output_buffer || @output
    end

    def capture(&block)
      parent ? parent.capture(&block) : super
    end

    # This is here to force #parent.capture to return the output
    def __in_erb_template; end

    private

    def process_output_buffer
      if parent.respond_to?(:output_buffer)
        parent.output_buffer.is_a?(String) ? parent.output_buffer : handle_rjs_buffer
      else
        nil
      end
    end

    def handle_rjs_buffer
      returning buffer = parent.output_buffer.dup.to_s do
        parent.output_buffer.clear
        parent.with_output_buffer(buffer) do
          buffer << parent.output_buffer.to_s
        end
      end
    end
  end

  class InlineRailsWidget < RailsWidget
    include Inline
  end
end
