module Erector
  module Mixin
    def erector(options = {}, &block)
      Erector::Widget.new(&block).to_s(options)
    end
  end
end
