module Erector

  # Abstract base class for Widget. This pattern allows Widget to include lots of nicely organized modules and still
  # have proper semantics for "super" in subclasses. See the rdoc for Widget for the list of all the included modules.
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

    [:helpers, :assigns, :output, :parent, :block].each do |attr|
      class_eval(<<-SRC, __FILE__, __LINE__ + 1)
        def #{attr}
          @_#{attr}
        end
      SRC
    end

    def initialize(assigns = {}, &block)
      unless assigns.is_a? Hash
        raise "Erector widgets are initialized with only a parameter hash. (Other parameters are passed to to_html, or the #widget method.)"
      end

      @_assigns = assigns

      assigns.each do |name, value|
        instance_variable_set(name.to_s[0..0] == '@' ? name : "@#{name}", value)
      end

      @_parent = eval("self", block.binding) if block
      @_block = block
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
    # max_length:: preferred maximum length of a line. Line wraps will only
    #              occur at space characters, so a long word may end up creating
    #              a line longer than this. If nil (default), then there is no
    #              arbitrary limit to line lengths, and only internal newline
    #              characters and prettyprinting will determine newlines in the
    #              output.
    # helpers:: a helpers object containing utility methods. Usually this is a
    #           Rails view object.
    # content_method_name:: in case you want to call a method other than
    #                       #content, pass its name in here.
    def to_html(options = {})
      raise "Erector::Widget#to_html takes an options hash, not a symbol. Try calling \"to_html(:content_method_name=> :#{options})\"" if options.is_a? Symbol
      _render(options).to_s
    end

    # alias for #to_html
    # @deprecated Please use {#to_html} instead
    def to_s(*args)
      unless defined? @@already_warned_to_s
        $stderr.puts "Erector::Widget#to_s is deprecated. Please use #to_html instead. Called from #{caller.first}"
        @@already_warned_to_s = true
      end
      to_html(*args)
    end

    # Entry point for rendering a widget (and all its children). Same as #to_html
    # only it returns an array, for theoretical performance improvements when using a
    # Rack server (like Sinatra or Rails Metal).
    #
    # # Options: see #to_html
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
      @_block.call(self) if @_block
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
    # performance than using +capture+ or +to_html+.
    def widget(target, assigns = {}, options = {}, &block)
      if target.is_a? Class
        target.new(assigns, &block)._render_via(self, options)
      else
        unless assigns.empty?
          raise "Unexpected second parameter. Did you mean to pass in assigns when you instantiated the #{target.class.to_s}?"
        end
        target._render_via(self, options, &block)
      end
    end

    # Creates a whole new output string, executes the block, then converts the
    # output string to a string and returns it as raw text. If at all possible
    # you should avoid this method since it hurts performance, and use +widget+
    # instead.
    def capture
      original, @_output = output, Output.new
      yield
      original.widgets.concat(output.widgets) # todo: test!!!
      output.to_s
    ensure
      @_output = original
    end

    protected
    def _render(options = {}, &block)
      @_block   = block if block
      @_parent  = options[:parent]  || parent
      @_helpers = options[:helpers] || parent
      @_output  = options[:output]
      @_output  = Output.new(options) unless output.is_a?(Output)

      output.widgets << self.class
      send(options[:content_method_name] || :content)
      output
    end

    def _render_via(parent, options = {}, &block)
      _render(options.merge(:parent  => parent,
                            :output  => parent.output,
                            :helpers => parent.helpers), &block)
    end
  end
end
