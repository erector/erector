module Erector
  class External < Struct.new(:type, :text, :options)
    def initialize(type, text, options = {})
      text = text.read if text.is_a? IO
      text = External.interpolate(text) if options[:interpolate] # todo: test
      super(type.to_sym, text, options)
    end
    
    def self.interpolate(s)
      eval("<<INTERPOLATE\n" + s + "\nINTERPOLATE").chomp
    end
    
    def ==(other)
      (self.type == other.type and
      self.text == other.text and
      self.options == other.options) ? true : false
    end
  end
  
end
