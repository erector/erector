module Erector
  
  # A Widget is the center of the Erector universe. 
  #
  # To create a widget, extend Erector::Widget and implement the +content+
  # method. Inside this method you may call any of the tag methods like +span+
  # or +p+ to emit HTML/XML tags. 
  #  
  # You can also define a widget on the fly by passing a block to +new+. This
  # block will get executed when the widget's +content+ method is called. See
  # the userguide for important details about the scope of this block when run --
  # http://erector.rubyforge.org/userguide.html#blocks
  #
  # To render a widget from the outside, instantiate it and call its +to_s+
  # method.
  #
  # A widget's +new+ method optionally accepts an options hash. Entries in
  # this hash are converted to instance variables.
  #
  # You can add runtime input checking via the +needs+ macro. See #needs. 
  # This mechanism is meant to ameliorate development-time confusion about
  # exactly what parameters are supported by a given widget, avoiding
  # confusing runtime NilClass errors.
  #  
  # To call one widget from another, inside the parent widget's +content+
  # method, instantiate the child widget and call the +widget+ method. This
  # assures that the same output stream is used, which gives better
  # performance than using +capture+ or +to_s+. It also preserves the
  # indentation and helpers of the enclosing class.
  #  
  # In this documentation we've tried to keep the distinction clear between
  # methods that *emit* text and those that *return* text. "Emit" means that
  # it writes to the output stream; "return" means that it returns a string
  # like a normal method and leaves it up to the caller to emit that string if
  # it wants.
  #
  # Now, seriously, after playing around a bit, go read the user guide. It's 
  # fun!
  class AbstractWidget
    @@prettyprint_default = false
    def prettyprint_default
      @@prettyprint_default
    end

    def self.prettyprint_default
      @@prettyprint_default
    end

    def self.prettyprint_default=(enabled)
      @@prettyprint_default = enabled
    end

    def self.inline(*args, &block)
      Class.new(self) do
        include Erector::Inline
      end.new(*args, &block)
    end

    RESERVED_INSTANCE_VARS = [:helpers, :assigns, :block, :output, :prettyprint, :indentation]

    attr_reader *RESERVED_INSTANCE_VARS
    attr_reader :parent # making this reserved causes breakage
    attr_writer :block
    
    def initialize(assigns={}, &block)
      unless assigns.is_a? Hash
        raise "Erector widgets are initialized with only a parameter hash. (Other parameters are passed to to_s, or the #widget method.)"
      end
      @assigns = assigns
      assign_instance_variables(assigns)
      unless @parent
        @parent = block ? eval("self", block.binding) : nil
      end
      @block = block
    end

    def output
      @output ||
        parent.respond_to?(:output) && parent.output ||
        raise("No output to emit to. @output must be set or the @parent must respond to :output")
    end

    # Entry point for rendering a widget (and all its children). This method
    # creates a new output string (if necessary), calls this widget's #content
    # method and returns the string.
    #
    # Options:
    # output:: the string to output to. Default: a new empty string
    # prettyprint:: whether Erector should add newlines and indentation.
    #               Default: the value of prettyprint_default (which is false
    #               by default). 
    # indentation:: the amount of spaces to indent. Ignored unless prettyprint
    #               is true.
    # helpers:: a helpers object containing utility methods. Usually this is a
    #           Rails view object.
    # content_method_name:: in case you want to call a method other than
    #                       #content, pass its name in here.
    def to_s(options = {})
      raise "Erector::Widget#to_s now takes an options hash, not a symbol. Try calling \"to_s(:content_method_name=> :#{options})\"" if options.is_a? Symbol
      _render(options).to_s
    end
    
    # Entry point for rendering a widget (and all its children). Same as #to_s
    # only it returns an array, for theoretical performance improvements when using a
    # Rack server (like Sinatra or Rails Metal).
    #
    # # Options: see #to_s
    def to_a(options = {})
      _render(options).to_a
    end

    # Template method which must be overridden by all widget subclasses.
    # Inside this method you call the magic #element methods which emit HTML
    # and text to the output string. If you call "super" (or don't override
    # +content+, or explicitly call "call_block") then your widget will
    # execute the block that was passed into its constructor. The semantics of
    # this block are confusing; make sure to read the rdoc for Erector#call_block
    def content
      call_block
    end
    
    # When this method is executed, the default block that was passed in to 
    # the widget's constructor will be executed. The semantics of this 
    # block -- that is, what "self" is, and whether it has access to
    # Erector methods like "div" and "text", and the widget's instance
    # variables -- can be quite confusing. The rule is, most of the time the
    # block is evaluated using "call" or "yield", which means that its scope
    # is that of the caller. So if that caller is not an Erector widget, it
    # will *not* have access to the Erector methods, but it *will* have access 
    # to instance variables and methods of the calling object.
    #   
    # If you want this block to have access to Erector methods then use 
    # Erector::Inline#content or Erector#inline.
    def call_block
      @block.call(self) if @block
    end

    # Emits a (nested) widget onto the current widget's output stream. Accepts
    # either a class or an instance. If the first argument is a class, then
    # the second argument is a hash used to populate its instance variables.
    # If the first argument is an instance then the hash must be unspecified
    # (or empty). If a block is passed to this method, then it gets set as the
    # rendered widget's block.
    #
    # This is the preferred way to call one widget from inside another. This
    # method assures that the same output string is used, which gives better
    # performance than using +capture+ or +to_s+.
    def widget(target, parameters={}, &block)
      child = if target.is_a? Class
        target.new(parameters, &block)
      else
        unless parameters.empty?
          raise "Unexpected second parameter. Did you mean to pass in variables when you instantiated the #{target.class.to_s}?"
        end
        target.block = block unless block.nil?
        target
      end
      output.widgets << child.class
      child.write_via(self)
    end

    # Creates a whole new output string, executes the block, then converts the
    # output string to a string and returns it as raw text. If at all possible
    # you should avoid this method since it hurts performance, and use
    # +widget+ or +write_via+ instead.
    def capture
      original_output = @output
      @output = Output.new
      yield
      @output.to_s
    ensure
      @output = original_output
    end

    protected
    def assign_instance_variables (instance_variables)
      instance_variables.each do |name, value|
        assign_instance_variable(name, value)
      end
    end

    def assign_instance_variable (name, value)
      raise ArgumentError, "Sorry, #{name} is a reserved variable name for Erector. Please choose a different name." if RESERVED_INSTANCE_VARS.include?(name)
      name = name.to_s
      ivar_name = (name[0..0] == '@' ? name : "@#{name}")
      instance_variable_set(ivar_name, value)
    end

    def _render(options)
      if !options[:output] && !options[:parent]
        options[:output] = new_output_from_options(options)
      end
      context(prepare_options(options)) do
        output.widgets << self.class
        _render_content_method(options[:content_method_name] || :content)
        output
      end
    end

    def prepare_options(options={})
      options[:parent] ||= @parent
      options[:helpers] ||= @parent
      new_output = if options[:output].is_a?(Output)
        options[:output]
      else
        # Assuming options[:output] is a string (Output#buffer)
        if options.include?(:prettyprint) || options.include?(:indentation) || options.include?(:output) || !options[:parent]
          new_output_from_options(options)
        else
          nil
        end
      end
      options.merge(:output => new_output)
    end

    def new_output_from_options(options)
      output_options = {}
      output_options[:prettyprint] = options[:prettyprint] if options.include?(:prettyprint)
      output_options[:indentation] = options[:indentation] if options.include?(:indentation)
      if options.include?(:output)
        Output.new(output_options) {options[:output]}
      else
        Output.new(output_options)
      end
    end

    # Overridden by Caching mixin.
    def _render_content_method(content_method)
      send(content_method)
    end

    def write_via(parent)
      context(:parent => parent, :helpers => parent.helpers) do
        _render_content_method(:content)
      end
    end

    def context(params={})
      original_parent = @parent
      original_output = @output
      original_helpers = @helpers
      params[:parent] && @parent = params[:parent]
      params[:output] && @output = params[:output]
      params[:helpers] && @helpers = params[:helpers]
      yield
    ensure
      @parent = original_parent
      @output = original_output if original_output # retain output after rendering, to check dependencies
      @helpers = original_helpers
    end
  end

  class Widget < AbstractWidget
    include Erector::HTML
    include Erector::Needs
    include Erector::Caching
    include Erector::Externals
    include Erector::Convenience
    include Erector::JQuery
    include Erector::AfterInitialize
    include Erector::Sass if Object.const_defined?(:Sass)
  end
end
