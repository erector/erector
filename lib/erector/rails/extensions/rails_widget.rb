module Erector
  class RailsWidget < Widget
    def self.inline(*args, &block)
      InlineRailsWidget.new(*args, &block)
    end

    def output
      process_output_buffer || @output
    end

    def capture_with_parent(&block)
      parent ? parent.capture(&block) : capture_without_parent(&block)
    end

    alias_method_chain :capture, :parent

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
