module Erector
  class Dependency
    attr_reader :type, :text, :options

    def initialize(type, text, options = {})
      text = text.read if text.is_a? IO
      text = self.class.interpolate(text) if options[:interpolate] # todo: test
      @type, @text, @options = type, text, options
    end

    def self.interpolate(s)
      eval("<<INTERPOLATE\n" + s + "\nINTERPOLATE").chomp
    end

    def ==(other)
      (self.type == other.type and
       self.text == other.text and
       self.options == other.options) ? true : false
    end

    def eql?(other)
      self == other
    end

    def hash
      # this is a fairly inefficient hash function but it does the trick for now
      "#{type}#{text}#{options}".hash
    end
  end
end
