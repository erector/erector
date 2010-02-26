module Erector
  class Dependency < Struct.new(:type, :text, :options)

    # Multiple forms:
    #   #new(type, text, options = {})
    #   #new(type, an_io, ... # file to be read
    #   #new('blah.js' ... infer :js
    #   #new('blah.css' ... infer :css
    def initialize(*args)
      if args[0].class == Symbol
        type = args.shift
      else
        type = /.+\.js/.match(args[0]) ? :js : :css
      end
      text = args[0]
      options = args[1] || {}
      text = text.read if text.is_a? IO
      text = self.class.interpolate(text) if options[:interpolate] # todo: test
      
      super(type, text, options)
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
