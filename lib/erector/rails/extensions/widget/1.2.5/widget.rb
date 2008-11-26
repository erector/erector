module Erector
  Widget.class_eval do
    attr_reader :_erbout

    after_initialize do
      @_erbout = doc.output
    end

    def output
      _erbout
    end

    def define_javascript_functions(*args)
      begin
        text raw(helpers.define_javascript_functions(*args))
      rescue => e
        puts e.backtrace.join("\n\t")
        raise e
      end
    end
  end
end