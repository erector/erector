module Erector
  class Widget
    class << self
      def all_tags
        Erector::Widget.full_tags + Erector::Widget.standalone_tags
      end

      def standalone_tags
        ['area', 'base', 'br', 'hr', 'img', 'input', 'link', 'meta']
      end

      def full_tags
        [
          'a', 'acronym', 'address', 'b', 'bdo', 'big', 'blockquote', 'body',
          'button', 'caption', 'cite', 'code', 'dd', 'del', 'div', 'dl', 'dt', 'em',
          'fieldset', 'form', 'h1', 'h2', 'h3', 'h4', 'h5', 'h6', 'head', 'html', 'i',
          'iframe', 'ins', 'kbd', 'label', 'legend', 'li', 'map',
          'noframes', 'noscript', 'ol', 'optgroup', 'option', 'p', 'param', 'pre',
          'samp', 'script', 'select', 'small', 'span', 'strong', 'style', 'sub', 'sup',
          'table', 'tbody', 'td', 'textarea', 'th', 'thead', 'title', 'tr', 'tt', 'u', 'ul', 'var'
        ]
      end
    end

    include ActionController::UrlWriter, Helpers
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
      fake_erbout
      @parent = block ? eval("self", block.binding) : nil
      @doc = doc
      @block = block
    end

    def render
      if @block
        instance_eval(&@block)
      end
    end

    def widget(widget_class, assigns={}, &block)
      child = widget_class.new(helpers, assigns, doc, &block)
      child.render
    end

    def h(content)
      text CGI.escapeHTML(content)
    end

    def open_tag(tag_name, attributes={})
      @doc << {'type' => 'open', 'tagName' => tag_name, 'attributes' => attributes}
    end

    def text(value)
      @doc << {'type' => 'text', 'value' => value}
      nil
    end

    def close_tag(tag_name)
      @doc << {'type' => 'close', 'tagName' => tag_name}
    end

    def instruct!(attributes={:version => "1.0", :encoding => "UTF-8"})
      @doc << {'type' => 'instruct', 'attributes' => attributes}
    end

    def javascript(*args, &blk)
      params = args[0] if args[0].is_a?(Hash)
      params ||= args[1] if args[1].is_a?(Hash)
      unless params
        params = {}
        args << params
      end
      params[:type] = "text/javascript"
      script(*args, &blk)
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
        value = arg0.to_s
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
    alias_method :element, :__element__
    
    def __standalone_element__(tag_name, attributes={})
      @doc << {'type' => 'standalone', 'tagName' => tag_name, 'attributes' => attributes}
    end
    alias_method :standalone_element, :__standalone_element__

    def capture(&block)
      begin
        original_doc = @doc
        @doc = HtmlParts.new
        yield
        @doc.to_s
      ensure
        @doc = original_doc
      end
    end

    def to_s(&blk)
      return @__to_s if @__to_s
      render(&blk)
      @__to_s = @doc.to_s
    end

    alias_method :inspect, :to_s

    full_tags.each do |tag_name|
      self.class_eval(
        "def #{tag_name}(*args, &block)\n" <<
        "  __element__('#{tag_name}', *args, &block)\n" <<
        "end",
        __FILE__,
        __LINE__ - 4
      )
    end

    standalone_tags.each do |tag_name|
      self.class_eval(
        "def #{tag_name}(*args, &block)\n" <<
        "  __standalone_element__('#{tag_name}', *args, &block)\n" <<
        "end",
        __FILE__,
        __LINE__ - 4
      )
    end

    protected
    def method_missing(name, *args, &block)
      block ||= lambda {} # captures self HERE
      if @parent
        @parent.send(name, *args, &block)
      else
        super
      end
    end
    
    def fake_erbout
      widget = self
      @helpers.metaclass.class_eval do
        define_method :concat do |some_text, binding|
          widget.text some_text
        end
      end
    end
  end
end