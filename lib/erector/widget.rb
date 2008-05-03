require 'cgi'

module Erector
  class Widget
    class << self
      def all_tags
        Erector::Widget.full_tags + Erector::Widget.empty_tags
      end

      def empty_tags
        ['area', 'base', 'br', 'hr', 'img', 'input', 'link', 'meta']
      end

      def full_tags
        [
          'a', 'acronym', 'address', 'b', 'bdo', 'big', 'blockquote', 'body',
          'button', 'caption', 'center', 'cite', 'code',
          'dd', 'del', 'div', 'dl', 'dt', 'em',
          'fieldset', 'form', 'h1', 'h2', 'h3', 'h4', 'h5', 'h6', 'head', 'html', 'i',
          'iframe', 'ins', 'kbd', 'label', 'legend', 'li', 'map',
          'noframes', 'noscript', 'ol', 'optgroup', 'option', 'p', 'param', 'pre',
          'samp', 'script', 'select', 'small', 'span', 'strong', 'style', 'sub', 'sup',
          'table', 'tbody', 'td', 'textarea', 'th', 'thead', 'title', 'tr', 'tt', 'u', 'ul', 'var'
        ]
      end

    end

    include ActionController::UrlWriter
    include Helpers
    attr_reader :helpers
    attr_reader :assigns
    attr_reader :doc
    attr_reader :block
    attr_reader :parent

    # Each item in @doc is an array containing three values: type, value, attributes
    def initialize(helpers=nil, assigns={}, doc = HtmlParts.new, &block)
      @assigns = assigns
      assigns.each do |name, value|
        instance_variable_set("@#{name}", value)
        metaclass.module_eval do
          attr_reader name
        end
      end
      @helpers = helpers
      @parent = block ? eval("self", block.binding) : nil
      @doc = doc
      @block = block
    end

### methods for other classes to call, left public for ease of testing and documentation

    def to_s(&blk)
      return @__to_s if @__to_s
      render(&blk)
      @__to_s = @doc.to_s
    end

    alias_method :inspect, :to_s

    def render
      if @block
        instance_eval(&@block)
      end
    end

    def render_to(doc)
      @doc = doc
      render
    end

    def render_for(parent)
      @parent = parent
      @doc = parent.doc
      render
    end

    def widget(widget_class, assigns={}, &block)
      child = widget_class.new(helpers, assigns, doc, &block)
      child.render
    end

    def html_escape
      return to_s
    end

### methods for subclasses to call

    def h(content)
      content.html_escape
    end

    def open_tag(tag_name, attributes={})
      @doc << {:type => :open, :tagName => tag_name, :attributes => attributes}
    end

    def text(value)
      @doc << {:type => :text, :value => value}
      nil
    end

    def raw(value)
      RawString.new(value.to_s)
    end

    def rawtext(value)
      text raw(value)
    end

    def nbsp(value)
      raw(value.html_escape.gsub(/ /,'&#160;'))
    end

    def close_tag(tag_name)
      @doc << {:type => :close, :tagName => tag_name}
    end

    def instruct(attributes={:version => "1.0", :encoding => "UTF-8"})
      @doc << {:type => :instruct, :attributes => attributes}
    end

    # Deprecated synonym of instruct
    def instruct!(attributes={:version => "1.0", :encoding => "UTF-8"})
      @doc << {:type => :instruct, :attributes => attributes}
    end

    def capture(&block)
      begin
        original_doc = @doc
        @doc = HtmlParts.new
        yield
        raw(@doc.to_s)
      ensure
        @doc = original_doc
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
      text "\n"
    end
    
    def element(*args, &block)
      __element__(*args, &block)
    end
      
    def empty_element(*args, &block)
      __empty_element__(*args, &block)
    end
      
### internal utility methods

protected

    def method_missing(name, *args, &block)
      block ||= lambda {} # captures self HERE
      if @parent
        @parent.send(name, *args, &block)
      else
        super
      end
    end

    def fake_erbout(&blk)
      widget = self
      @helpers.metaclass.class_eval do
        raise "Cannot nest fake_erbout" if instance_methods.include?('concat_without_erector')
        alias_method :concat_without_erector, :concat
        define_method :concat do |some_text, binding|
          widget.rawtext(some_text)
        end
      end
      yield
    ensure
      @helpers.metaclass.class_eval do
        alias_method :concat, :concat_without_erector
        remove_method :concat_without_erector
      end
    end
    
private

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
      @doc << {:type => :empty, :tagName => tag_name, :attributes => attributes}
    end
    
  end
end
