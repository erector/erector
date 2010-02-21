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

    # externals
    
    
    
    def self.external(type, value, options = {})
      @externals ||= []
      type = type.to_sym
      x = External.new(type, value, options)
      @externals << x unless @externals.include?(x)
    end
    
    # returns all externals of the given type from this class and all its
    # superclasses
    def self.externals(type)
      @externals ||= []
      
      type = type.to_sym
      parent_externals = if superclass.respond_to?(:externals)
        superclass.externals(type)
      else
        []
      end

      my_externals = @externals.select do |external|
        external.type == type
      end
      
      (parent_externals + my_externals).uniq
    end

    # caching

    @cachable = false

    def self.cacheable(value = true)
      @cachable = value
    end
    
    def self.cachable(value = true)
      @cachable = value
    end
    
    def self.cachable?
      if @cachable.nil?
        superclass.respond_to?(:cachable?) && superclass.cachable?
      else
        @cachable
      end
    end
    

    class << self
      def after_initialize(instance=nil, &blk)
        if blk
          after_initialize_parts << blk
        elsif instance
          if superclass.respond_to?(:after_initialize)
            superclass.after_initialize instance
          end
          after_initialize_parts.each do |part|
            instance.instance_eval &part
          end
        else
          raise ArgumentError, "You must provide either an instance or a block"
        end
      end
      
      protected
      def after_initialize_parts
        @after_initialize_parts ||= []
      end
      
    end


    public
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

    @@cache = nil
    def cache
      self.class.cache
    end

    def self.cache
      @@cache
    end

    def self.cache=(c)
      @@cache = c
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
      self.class.after_initialize self
    end

#-- methods for other classes to call, left public for ease of testing and documentation
#++

    public
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
    
    # Render (like to_s) but adding newlines and indentation.
    # This is a convenience method; you may just want to call to_s(:prettyprint => true)
    # so you can pass in other rendering options as well.  
    def to_pretty
      to_s(:prettyprint => true)
    end
    
    # Render (like to_s) but stripping all tags.
    def to_text
      CGI.unescapeHTML(to_s(:prettyprint => false).gsub(/<[^>]*>/, ''))
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
    def to_s(options = {}, &blk)
      raise "Erector::Widget#to_s now takes an options hash, not a symbol. Try calling \"to_s(:content_method_name=> :#{options})\"" if options.is_a? Symbol
      raw(_render(options, &blk).to_s)
    end
    
    # Entry point for rendering a widget (and all its children). Same as #to_s
    # only it returns an array, for theoretical performance improvements when using a
    # Rack server (like Sinatra or Rails Metal).
    #
    # # Options: see #to_s
    def to_a(options = {}, &blk)
      _render(options, &blk).to_a
    end

    def _render(options = {}, &blk)
      options = {
        :helpers => @parent,
        :parent => @parent,
        :content_method_name => :content,
      }.merge(options)
      
      if options[:output] && (options[:output].is_a? Output)
        output = options[:output]
      else
        output_options = {}
        [:prettyprint, :indentation, :output].each do |opt|
          output_options[opt] = options[opt] unless options[opt].nil?
        end
        output = Output.new(output_options)
      end

      context(options[:parent], output, options[:helpers]) do
        @output.widgets << self.class
        if should_cache?
          if (cached_string = cache[self.class, @assigns])
            output << cached_string
          else
            send(options[:content_method_name], &blk)
            cache[self.class, @assigns] = output.to_s
          end
        else
          send(options[:content_method_name], &blk)
        end
        output
      end
    end
    
    def render_with_externals(options_to_external_renderer = {})
      output = Erector::Output.new
      self.to_s(:output => output)
      nested_widgets = output.widgets.to_a
      externals = ExternalRenderer.new({:classes => nested_widgets}.merge(options_to_external_renderer)).to_s(:output => output)
      output.to_a
    end

    def render_externals(options_to_external_renderer = {})
      output_for_externals = Erector::Output.new
      nested_widgets = output.widgets
      externalizer = ExternalRenderer.new({:classes => nested_widgets}.merge(options_to_external_renderer))
      externalizer._render(:output => output_for_externals)
      output_for_externals.to_a
    end

    def should_cache?
      cache && @block.nil? && self.class.cachable?
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

    def write_via(parent)
      context(parent, parent.output, parent.helpers) do
        if should_cache?
          cached_string = cache[self.class, @assigns]
          if cached_string.nil?
            cached_string = capture { content }
            cache[self.class, @assigns] = cached_string
          end
          rawtext cached_string
        else
          content # call the subclass' content method
        end
      end
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

#-- methods for subclasses to call
#++

    # Returns text which will *not* be HTML-escaped.
    def raw(value)
      RawString.new(value.to_s)
    end
    
    # Emits the result of joining the elements in array with the separator.
    # The array elements and separator can be Erector::Widget objects,
    # which are rendered, or strings, which are html-escaped and output.
    def join(array, separator)
      first = true
      array.each do |widget_or_text|
        if !first
          text separator
        end
        first = false
        text widget_or_text
      end
    end

    # Creates a whole new output string, executes the block, then converts the
    # output string to a string and returns it as raw text. If at all possible
    # you should avoid this method since it hurts performance, and use
    # +widget+ or +write_via+ instead.
    def capture(&block)
      raw(with_output_buffer(&block))
    end

    def with_output_buffer(buffer='')
      begin
        original_output = @output
        @output = Output.new(:output => buffer)
        yield
        buffer
      ensure
        @output = original_output
      end
    end
    
    # Convenience method to emit a css file link, which looks like this:
    # <link href="erector.css" rel="stylesheet" type="text/css" />
    # The parameter is the full contents of the href attribute, including any ".css" extension.
    #
    # If you want to emit raw CSS inline, use the #style method instead.
    def css(href, options = {})
      link({:rel => 'stylesheet', :type => 'text/css', :href => href}.merge(options))
    end
    
    # Convenience method to emit an anchor tag whose href and text are the same,
    # e.g. <a href="http://example.com">http://example.com</a>
    def url(href, options = {})
      a href, ({:href => href}.merge(options))
    end

    # makes a unique id based on the widget's class name and object id
    # that you can use as the HTML id of an emitted element
    def dom_id
      "#{self.class.name.gsub(/:+/,"_")}_#{self.object_id}"
    end

    # emits a jQuery script that is to be run on document ready
    def jquery(txt)
      javascript do
        jquery_ready txt
      end
    end

    protected
    def jquery_ready(txt)
      rawtext "\n"
      rawtext "jQuery(document).ready(function($){\n"
      rawtext txt
      rawtext "\n});"
    end

    def jquery_load(txt)
      rawtext "\n"
      rawtext "jQuery(document).load(function($){\n"
      rawtext txt
      rawtext "\n});"
    end
    
### internal utility methods

protected
    def context(parent, output, helpers = nil)
      #TODO: pass in options hash, maybe, instead of parameters
      original_parent = @parent
      original_output = @output
      original_helpers = @helpers
      @parent = parent
      @output = output
      @helpers = helpers
      yield
    ensure
      @parent = original_parent
      @output = original_output unless original_output.nil? # retain output after rendering, to check externals
      @helpers = original_helpers
    end
  end

  class Widget < AbstractWidget
    include Erector::HTML
    include Erector::Needs
  end
end
