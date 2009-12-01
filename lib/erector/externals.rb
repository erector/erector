module Erector
  class External < Struct.new(:type, :klass, :text, :options)
    def initialize(type, klass, text, options = {})
      text = External.interpolate(text.read) if text.is_a? IO
      super(type.to_sym, klass, text, options)
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
  
  module Externals
    def externals(type, klass = nil)
      type = type.to_sym
      (@@externals ||= []).select do |x| 
        x.type == type && 
        (klass.nil? || x.klass == klass)
      end
    end

    def external(type, value, options = {})
      type = type.to_sym
      klass = self # since it's a class method, self should be the class itself
      x = External.new(type, klass, value, options)
      @@externals ||= []
      @@externals << x unless @@externals.include?(x)
    end
  end

end
