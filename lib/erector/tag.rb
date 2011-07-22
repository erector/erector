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
    # @param snake whether to covert the method name into "snake case" (aka underscorized). Default: false
    #
    def initialize(name, *params)
      @name = name.to_s
      @method_name = if params.first.is_a? String
        params.shift
      else
        @name
      end
      @self_closing = params.include?(:self_closing)
      @inline = params.include?(:inline)
      @method_name = snake_case(@method_name) if params.include?(:snake_case)
    end

    attr_reader :name, :method_name

    def self_closing?
      @self_closing
    end

    def newliney?
      !@inline
    end

    def inline?
      @inline
    end

    ##
    # Convert to snake case.
    #
    #   "FooBar".snake_case           #=> "foo_bar"
    #   "HeadlineCNNNews".snake_case  #=> "headline_cnn_news"
    #   "CNN".snake_case              #=> "cnn"
    #
    # @return [String] Receiver converted to snake case.
    #
    # @api public
    # borrowed from https://github.com/datamapper/extlib/blob/master/lib/extlib/string.rb
    def snake_case(s)
      if s.match(/\A[A-Z]+\z/)
        s.downcase
      else
        s.gsub(/([A-Z]+)([A-Z][a-z])/, '\1_\2').
         gsub(/([a-z])([A-Z])/, '\1_\2').
         downcase
      end
    end

  end

end
