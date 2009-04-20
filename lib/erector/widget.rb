module Erector
  
  # A Widget is the center of the Erector universe. 
  #
  # To create a widget, extend Erector::Widget and implement 
  # the +write+ method. Inside this method you may call any of the tag methods like +span+ or +p+ to emit HTML/XML
  # tags. 
  # 
  # You can also define a widget on the fly by passing a block to +new+. This block will get executed when the widget's
  # +write+ method is called.
  #
  # To render a widget from the outside, instantiate it and call its +to_s+ method.
  #
  # A widget's +new+ method optionally accepts an options hash. Entries in this hash are converted to instance
  # variables, and +attr_reader+ accessors are defined for each.
  #
  # TODO: You can add runtime input checking via the +needs+ macro. If any of the variables named via 
  # +needs+ are absent, an exception is thrown. Optional variables are specified with +wants+. If a variable appears
  # in the options hash that is in neither the +needs+ nor +wants+ lists, then that too provokes an exception. 
  # This mechanism is meant to ameliorate development-time confusion about exactly what parameters are supported
  # by a given widget, avoiding confusing runtime NilClass errors.
  # 
  # To call one widget from another, inside the parent widget's write method, instantiate the child widget and call 
  # its +write_via+ method, passing in +self+ (or self.output if you prefer). This assures that the same output
  # is used, which gives better performance than using +capture+ or +to_s+.
  # 
  # In this documentation we've tried to keep the distinction clear between methods that *emit* text and those that
  # *return* text. "Emit" means that it writes to the output stream; "return" means that it returns a string
  # like a normal method and leaves it up to the caller to emit that string if it wants.
  class Widget
    class << self
      def all_tags
        Erector::Widget.full_tags + Erector::Widget.empty_tags
      end

      # tags which are always self-closing
      def empty_tags
        ['area', 'base', 'br', 'col', 'frame', 
        'hr', 'img', 'input', 'link', 'meta']
      end

      # tags which can contain other stuff
      def full_tags
        [
          'a', 'abbr', 'acronym', 'address', 
          'b', 'bdo', 'big', 'blockquote', 'body', 'button', 
          'caption', 'center', 'cite', 'code', 'colgroup',
          'dd', 'del', 'dfn', 'div', 'dl', 'dt', 'em',
          'fieldset', 'form', 'frameset',
          'h1', 'h2', 'h3', 'h4', 'h5', 'h6', 'head', 'html', 'i',
          'iframe', 'ins', 'kbd', 'label', 'legend', 'li', 'map',
          'noframes', 'noscript', 
          'object', 'ol', 'optgroup', 'option', 'p', 'param', 'pre',
          'q', 's',
          'samp', 'script', 'select', 'small', 'span', 'strike',
          'strong', 'style', 'sub', 'sup',
          'table', 'tbody', 'td', 'textarea', 'tfoot', 
          'th', 'thead', 'title', 'tr', 'tt', 'u', 'ul', 'var'
        ]
      end

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

    @@prettyprint_default = false
    def prettyprint_default
      @@prettyprint_default
    end

    def self.prettyprint_default=(enabled)
      @@prettyprint_default = enabled
    end

    NON_NEWLINEY = {'i' => true, 'b' => true, 'small' => true,
      'img' => true, 'span' => true, 'a' => true,
      'input' => true, 'textarea' => true, 'button' => true, 'select' => true
    }

    SPACES_PER_INDENT = 2

    attr_reader :helpers, :assigns, :block, :parent, :output, :prettyprint, :indentation
    attr_accessor :enable_prettyprint

    def initialize(assigns={}, &block)
      @assigns = assigns
      assign_locals(assigns)
      @parent = block ? eval("self", block.binding) : nil
      @block = block
      self.class.after_initialize self
      @prettyprint = prettyprint_default
    end

#-- methods for other classes to call, left public for ease of testing and documentation
#++

  #todo: protected
    def prepare(output, indentation = 0, helpers = nil)
      @output = output
      @at_start_of_line = true
      raise "indentation must be a number, not #{indentation.inspect}" unless indentation.is_a? Fixnum
      @indentation = indentation
      @helpers = helpers
    end

    public
    def assign_locals(local_assigns)
      local_assigns.each do |name, value| 
        instance_variable_set("@#{name}", value)
        metaclass.module_eval do
          attr_reader name
        end
      end
    end
    
    # Set whether Erector should add newlines and indentation in to_s.
    # This is an experimental feature and is subject to change
    # (either in terms of how it is enabled, or in terms of
    # what decisions Erector makes about where to add whitespace).
    # This flag should be set prior to any rendering being done
    # (for example, calls to to_s or to_pretty).
    def enable_prettyprint(enable)
      self.prettyprint = enable
      self
    end

    # Render (like to_s) but adding newlines and indentation.
    def to_pretty
      enable_prettyprint(true).to_s
    end

    # Entry point for rendering a widget (and all its children). This method creates a new output string,
    # calls this widget's #write method and returns the string.
    #
    # If it's called again later 
    # then it returns the earlier rendered string, which may lead to higher performance, but may have confusing
    # effects if some underlying state has changed. In general we recommend you create a new instance of every
    # widget for each write, unless you know what you're doing.
    def to_s(write_method_name = :write, &blk)
      # The @__to_s variable is used as a cache. 
      # If it's useful we should add a test for it.  -ac
      return @__to_s if @__to_s
      prepare("")
      send(write_method_name, &blk)
      @__to_s = output.to_s
    end
    
    alias_method :inspect, :to_s

    # Template method which must be overridden by all widget subclasses. Inside this method you call the magic
    # #element methods which emit HTML and text to the output string.
    def write
      if @block
        instance_eval(&@block)
      end
    end

    # To call one widget from another, inside the parent widget's write method, instantiate the child widget and call 
    # its +write_via+ method, passing in +self+ (or self.output if you prefer). This assures that the same output string
    # is used, which gives better performance than using +capture+ or +to_s+.
    def write_via(widget)
      @parent = widget
      @prettyprint = widget.prettyprint
      prepare(widget.output, widget.indentation, widget.helpers)
      write
    end

    # TODO: deprecate?
    # Convenience method for on-the-fly widgets. This is a way of making
    # a sub-widget which still has access to the methods of the parent class.
    # This is an experimental erector feature which may disappear in future
    # versions of erector (see #widget in widget_spec in the Erector tests).
    def widget(widget_class, assigns={}, &block)
      child = widget_class.new(assigns, &block)
      child.prepare(output, @indentation, helpers)
      child.write
    end

    # (Should we make this hidden?)
    def html_escape
      return to_s
    end

#-- methods for subclasses to call
#++

    # Internal method used to emit an HTML/XML element, including an open tag, attributes (optional, via the default hash), 
    # contents (also optional), and close tag. 
    #
    # Using the arcane powers of Ruby, there are magic methods that call +element+ for all the standard
    # HTML tags, like +a+, +body+, +p+, and so forth. Look at the source of #full_tags for the full list.
    # Unfortunately, this big mojo confuses rdoc, so we can't see each method in this rdoc page, but trust
    # us, they're there.
    #
    # When calling one of these magic methods, put attributes in the default hash. If there is a string parameter,
    # then it is used as the contents. If there is a block, then it is executed (yielded), and the string parameter is ignored.
    # The block will usually be in the scope of the child widget, which means it has access to all the 
    # methods of Widget, which will eventually end up appending text to the +output+ string. See how
    # elegant it is? Not confusing at all if you don't think about it.
    #
    def element(*args, &block)
      __element__(*args, &block)
    end
  
    # Internal method used to emit a self-closing HTML/XML element, including a tag name and optional attributes
    # (passed in via the default hash).
    # 
    # Using the arcane powers of Ruby, there are magic methods that call +empty_element+ for all the standard
    # HTML tags, like +img+, +br+, and so forth. Look at the source of #empty_tags for the full list.
    # Unfortunately, this big mojo confuses rdoc, so we can't see each method in this rdoc page, but trust
    # us, they're there.
    #
    def empty_element(*args, &block)
      __empty_element__(*args, &block)
    end

    # Returns an HTML-escaped version of its parameter. Leaves the output string untouched. Note that
    # the #text method automatically HTML-escapes its parameter, so be careful *not* to do something like
    # text(h("2<4")) since that will double-escape the less-than sign (you'll get "2&amp;lt;4" instead of
    # "2&lt;4").
    def h(content)
      content.html_escape
    end

    # Emits an open tag, comprising '<', tag name, optional attributes, and '>'
    def open_tag(tag_name, attributes={})
      indent_for_open_tag(tag_name)
      @indentation += SPACES_PER_INDENT

      output.concat "<#{tag_name}#{format_attributes(attributes)}>"
      @at_start_of_line = false
    end

    # Emits text.  If a string is passed in, it will be HTML-escaped.
    # If a widget or the result of calling methods such as raw
    # is passed in, the HTML will not be HTML-escaped again.
    # If another kind of object is passed in, the result of calling
    # its to_s method will be treated as a string would be.
    def text(value)
      output.concat(value.html_escape)
      @at_start_of_line = false
      nil
    end

    # Returns text which will *not* be HTML-escaped.
    def raw(value)
      RawString.new(value.to_s)
    end

    # Emits text which will *not* be HTML-escaped. Same effect as text(raw(s))
    def rawtext(value)
      text raw(value)
    end

    # Returns a copy of value with spaces replaced by non-breaking space characters.
    # With no arguments, return a single non-breaking space.
    # The output uses the escaping format '&#160;' since that works
    # in both HTML and XML (as opposed to '&nbsp;' which only works in HTML).
    def nbsp(value = " ")
      raw(value.html_escape.gsub(/ /,'&#160;'))
    end
    
    # Return a character given its unicode code point or unicode name.
    def character(code_point_or_name)
      if code_point_or_name.is_a?(Symbol)
        found = Erector::CHARACTERS[code_point_or_name]
        if found.nil?
          raise "Unrecognized character #{code_point_or_name}"
        end
        raw("&#x#{sprintf '%x', found};")
      elsif code_point_or_name.is_a?(Integer)
        raw("&#x#{sprintf '%x', code_point_or_name};")
      else
        raise "Unrecognized argument to character: #{code_point_or_name}"
      end
    end

    # Emits a close tag, consisting of '<', tag name, and '>'
    def close_tag(tag_name)
      @indentation -= SPACES_PER_INDENT
      indent()

      output.concat("</#{tag_name}>")

      if newliney(tag_name)
        _newline
      end
    end
    
    # Emits the result of joining the elements in array with the separator.
    # The array elements and separator can be Erector::Widget objects,
    # which are rendered, or strings, which are quoted and output.
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

    # Emits an XML instruction, which looks like this: <?xml version=\"1.0\" encoding=\"UTF-8\"?>
    def instruct(attributes={:version => "1.0", :encoding => "UTF-8"})
      output.concat "<?xml#{format_sorted(sort_for_xml_declaration(attributes))}?>"
    end

    # Creates a whole new output string, executes the block, then converts the output string to a string and
    # emits it as raw text. If at all possible you should avoid this method since it hurts performance,
    # and use #write_via instead.
    def capture(&block)
      begin
        original_output = output
        @output = ""
        yield
        raw(output.to_s)
      ensure
        @output = original_output
      end
    end

    full_tags.each do |tag_name|
      self.class_eval(
        "def #{tag_name}(*args, &block)\n" <<
        "  __element__('#{tag_name}', *args, &block)\n" <<
        "end",
        __FILE__,
        __LINE__ - 4
      )
    end

    empty_tags.each do |tag_name|
      self.class_eval(
        "def #{tag_name}(*args, &block)\n" <<
        "  __empty_element__('#{tag_name}', *args, &block)\n" <<
        "end",
        __FILE__,
        __LINE__ - 4
      )
    end

    # Emits a javascript block inside a +script+ tag, wrapped in CDATA doohickeys like all the cool JS kids do.
    def javascript(*args, &block)
      if args.length > 2
        raise ArgumentError, "Cannot accept more than two arguments"
      end
      attributes, value = nil, nil
      arg0 = args[0]
      if arg0.is_a?(Hash)
        attributes = arg0
      else
        value = arg0
        arg1 = args[1]
        if arg1.is_a?(Hash)
          attributes = arg1
        end
      end
      attributes ||= {}
      attributes[:type] = "text/javascript"
      open_tag 'script', attributes

      # Shouldn't this be a "cdata" HtmlPart?
      # (maybe, but the syntax is specific to javascript; it isn't
      # really a generic XML CDATA section.  Specifically,
      # ]]> within value is not treated as ending the
      # CDATA section by Firefox2 when parsing text/html,
      # although I guess we could refuse to generate ]]>
      # there, for the benefit of XML/XHTML parsers).
      rawtext "\n// <![CDATA[\n"
      if block
        instance_eval(&block)
      else
        rawtext value
      end
      rawtext "\n// ]]>\n"

      close_tag 'script'
      rawtext "\n"
    end
    
    # Convenience method to emit a css file link, which looks like this: <link href="erector.css" rel="stylesheet" type="text/css" />
    # The parameter is the full contents of the href attribute, including any ".css" extension. 
    #
    # If you want to emit raw CSS inline, use the #script method instead.
    def css(href)
      link :rel => 'stylesheet', :type => 'text/css', :href => href
    end
    
    # Convenience method to emit an anchor tag whose href and text are the same, e.g. <a href="http://example.com">http://example.com</a>
    def url(href)
      a href, :href => href
    end

    def newliney(tag_name)
      @prettyprint and !NON_NEWLINEY.include?(tag_name)
    end    
    
### internal utility methods

protected

    # This is part of the sub-widget/parent feature (see #widget method).
    def method_missing(name, *args, &block)
      block ||= lambda {} # captures self HERE
      if @parent
        @parent.send(name, *args, &block)
      else
        super
      end
    end

    def __element__(tag_name, *args, &block)
      if args.length > 2
        raise ArgumentError, "Cannot accept more than three arguments"
      end
      attributes, value = nil, nil
      arg0 = args[0]
      if arg0.is_a?(Hash)
        attributes = arg0
      else
        value = arg0
        arg1 = args[1]
        if arg1.is_a?(Hash)
          attributes = arg1
        end
      end
      attributes ||= {}
      open_tag tag_name, attributes
      if block
        instance_eval(&block)
      else
        text value
      end
      close_tag tag_name
    end

    def __empty_element__(tag_name, attributes={})
      indent_for_open_tag(tag_name)

      output.concat "<#{tag_name}#{format_attributes(attributes)} />"

      if newliney(tag_name)
        newline
      end
    end
    
    def _newline
      return unless @prettyprint      
      output.concat "\n"
      @at_start_of_line = true
    end

    def indent_for_open_tag(tag_name)
      return unless @prettyprint      
      if !@at_start_of_line && newliney(tag_name)
        _newline
      end
      indent()
    end

    def indent()
      if @at_start_of_line
        output.concat " " * @indentation
      end
    end

    def format_attributes(attributes)
      if !attributes || attributes.empty?
        ""
      else
        format_sorted(sorted(attributes))
      end
    end

    def format_sorted(sorted)
      results = ['']
      sorted.each do |key, value|
        if value
          if value.is_a?(Array)
            value = [value].flatten.join(' ')
          end
          results << "#{key}=\"#{value.html_escape}\""
        end
      end
      return results.join(' ')
    end

    def sorted(attributes)
      stringized = []
      attributes.each do |key, value|
        stringized << [key.to_s, value]
      end
      return stringized.sort
    end

    def sort_for_xml_declaration(attributes)
      # correct order is "version, encoding, standalone" (XML 1.0 section 2.8).
      # But we only try to put version before encoding for now.
      stringized = []
      attributes.each do |key, value|
        stringized << [key.to_s, value]
      end
      return stringized.sort{|a, b| b <=> a}
    end
  end
end
