module Erector
  module JQuery
    # emits a jQuery script that is to be run on document ready
    def jquery(txt)
      javascript do
        jquery_ready txt
      end
    end

    protected
    def jquery_ready(txt)
      rawtext "\n"
      rawtext "jQuery(document).ready(function($){\n"
      rawtext txt
      rawtext "\n});"
    end

    def jquery_load(txt)
      rawtext "\n"
      rawtext "jQuery(document).load(function($){\n"
      rawtext txt
      rawtext "\n});"
    end
  end
end
