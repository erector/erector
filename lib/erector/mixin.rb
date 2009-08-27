module Erector
  module Mixin
    # Executes the block as if it were the content body of a fresh Erector::Inline,
    # and returns the #to_s value. Since it executes inside the new widget it does not
    # have access to instance variables of the caller, although it does
    # have access to bound variables. 
    def erector(options = {}, &block)
      Erector::Inline.new(&block).to_s(options)
    end
  end
end
