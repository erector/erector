module Erector
  module JQuery
    # emits a jQuery script that is to be run on document ready or load.
    # Usage (from inside a widget method):
    #     jquery "alert('hi')" => a jquery ready handler
    # or
    #     jquery :load, "alert('hi')" => a jquery load handler
    #
    def jquery(*args)
      if args.length == 2
        event, txt = args
      elsif args.length == 1
        event, txt = :ready, args[0]
      else
        raise "Wrong number of arguments to Erector::Widget#jquery. Usage: jquery(event, script)"
      end
      javascript do
        rawtext "\n"
        rawtext "jQuery(document).#{event}(function($){\n"
        rawtext txt
        rawtext "\n});"
      end
    end
  end
end
