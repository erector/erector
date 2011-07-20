module Erector

  # Defines a type of tag (not an actual element with attributes and contents)
  class Tag

    # Pass the self_closing and inline params as symbols, e.g.
    #
    # Tag.new("i", :inline)
    # Tag.new("input", :inline, :self_closing)
    #
    # @param name the name of the tag, e.g. "div"
    # @param self_closing whether it can (false) or cannot (true) contain text or other elements. Default: false
    # @param inline whether it should appear in line with other elements (true) or on a line by itself (false) in pretty mode. Default: false
    def initialize(name, *params)
      @name = name.to_s
      @self_closing = params.include?(:self_closing)
      @inline = params.include?(:inline)
    end

    attr_reader :name

    def self_closing?
      @self_closing
    end

    def newliney?
      !@inline
    end

    def inline?
      @inline
    end
  end

end
