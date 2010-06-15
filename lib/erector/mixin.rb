module Erector
  module Mixin
    # Executes the block as if it were the content body of a fresh Erector::Inline,
    # and returns the #to_html value. Since it executes inside the new widget it does not
    # have access to instance variables of the caller, although it does
    # have access to bound variables. Funnily enough, the options are passed in to both
    # to_html *and* to the widget itself, so they show up as instance variables.
    def erector(options = {}, &block)
      Erector.inline(options, &block).to_html(options)
    end
  end
end
