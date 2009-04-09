module Erector
  class RailsWidget < Widget
    attr_reader :_erbout

    after_initialize do
      @_erbout = output
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

require "#{File.dirname(__FILE__)}/rails_widget/helpers"
