module Erector
  module JQuery
    # Emits a jQuery script, inside its own script tag, that is to be run on document ready or load.
    #
    # Usage (from inside a widget method):
    # jquery "alert('hi')" :: a jquery ready handler
    # jquery "alert('hi')", :id => 'foo' :: a jquery ready handler, with attributes in the script tag
    # jquery :load, "alert('hi')" :: a jquery load handler
    #
    def jquery(*args)
      event = if args.first.is_a? Symbol
        args.shift
      else
        :ready
      end
      txt = args.shift
      attributes = args.shift || {}

      javascript attributes do
        rawtext "\n"
        rawtext "jQuery(document).#{event}(function($){\n"
        rawtext txt
        rawtext "\n});"
      end
    end

  end
end
