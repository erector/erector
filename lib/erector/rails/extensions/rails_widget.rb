module Erector
  class RailsWidget < Widget
    def output
      process_output_buffer || @output
    end

    def capture_with_helpers(&block)
      helpers ? helpers.capture(&block) : capture_without_helpers(&block)
    end

    alias_method_chain :capture, :helpers

    # This is here to force #helpers.capture to return the output
    def __in_erb_template; end

    private

    def process_output_buffer
      if helpers.respond_to?(:output_buffer)
        buffer = helpers.output_buffer
        buffer.is_a?(String) ? buffer : handle_rjs_buffer
      else
        nil
      end
    end

    def handle_rjs_buffer
      returning buffer = helpers.output_buffer.dup.to_s do
        helpers.output_buffer.clear
        helpers.with_output_buffer(buffer) do
          buffer << helpers.output_buffer.to_s
        end
      end
    end
  end
end

require "#{File.dirname(__FILE__)}/rails_widget/helpers"
