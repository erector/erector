module Erector
  Widget.class_eval do
    def output
      if helpers.respond_to?(:output_buffer)
        helpers.output_buffer
      else
        @output
      end
    end

    def capture_with_helpers(&block)
      if helpers
        helpers.capture(&block)
      else
        capture_without_helpers(&block)
      end
    end
    alias_method_chain :capture, :helpers

    # This is here to force #helpers.capture to return the output
    def __in_erb_template; end
  end
end