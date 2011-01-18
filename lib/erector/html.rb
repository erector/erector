module Erector
  module HTML
    module ClassMethods
      # Tags which are always self-closing. Click "[show source]" to see the full list.
      def empty_tags
        ['area', 'base', 'br', 'col', 'embed', 'frame',
        'hr', 'img', 'input', 'link', 'meta', 'param']
      end

      # Tags which can contain other stuff. Click "[show source]" to see the full list.
      def full_tags
        [
          'a', 'abbr', 'acronym', 'address', 'article', 'aside', 'audio',
          'b', 'bdo', 'big', 'blockquote', 'body', 'button',
          'canvas', 'caption', 'center', 'cite', 'code', 'colgroup', 'command',
          'datalist', 'dd', 'del', 'details', 'dfn', 'dialog', 'div', 'dl', 'dt',
          'em',
          'fieldset', 'figure', 'footer', 'form', 'frameset',
          'h1', 'h2', 'h3', 'h4', 'h5', 'h6', 'head', 'header', 'hgroup', 'html', 'i',
          'iframe', 'ins', 'keygen', 'kbd', 'label', 'legend', 'li',
          'map', 'mark', 'meter',
          'nav', 'noframes', 'noscript',
          'object', 'ol', 'optgroup', 'option',
          'p', 'pre', 'progress',
          'q', 'ruby', 'rt', 'rp', 's',
          'samp', 'script', 'section', 'select', 'small', 'source', 'span', 'strike',
          'strong', 'style', 'sub', 'sup',
          'table', 'tbody', 'td', 'textarea', 'tfoot',
          'th', 'thead', 'time', 'title', 'tr', 'tt',
          'u', 'ul',
          'var', 'video'
        ]
      end

      def all_tags
        full_tags + empty_tags
      end

      def def_empty_tag_method(tag_name)
        self.class_eval(<<-SRC, __FILE__, __LINE__ + 1)
          def #{tag_name}(*args, &block)
            __empty_element__('#{tag_name}', *args, &block)
          end
        SRC
      end

      def def_full_tag_method(tag_name)
        self.class_eval(<<-SRC, __FILE__, __LINE__ + 1)
          def #{tag_name}(*args, &block)
              __element__(false, '#{tag_name}', *args, &block)
          end

          def #{tag_name}!(*args, &block)
            __element__(true, '#{tag_name}', *args, &block)
          end
        SRC
      end
    end

    def self.included(base)
      base.extend ClassMethods

      base.full_tags.each do |tag_name|
        base.def_full_tag_method(tag_name)
      end

      base.empty_tags.each do |tag_name|
        base.def_empty_tag_method(tag_name)
      end
    end

    # Internal method used to emit an HTML/XML element, including an open tag,
    # attributes (optional, via the default hash), contents (also optional),
    # and close tag.
    #
    # Using the arcane powers of Ruby, there are magic methods that call
    # +element+ for all the standard HTML tags, like +a+, +body+, +p+, and so
    # forth. Look at the source of #full_tags for the full list.
    # Unfortunately, this big mojo confuses rdoc, so we can't see each method
    # in this rdoc page, but trust us, they're there.
    #
    # When calling one of these magic methods, put attributes in the default
    # hash. If there is a string parameter, then it is used as the contents.
    # If there is a block, then it is executed (yielded), and the string
    # parameter is ignored. The block will usually be in the scope of the
    # child widget, which means it has access to all the methods of Widget,
    # which will eventually end up appending text to the +output+ string. See
    # how elegant it is? Not confusing at all if you don't think about it.
    #
    def element(*args, &block)
      __element__(false, *args, &block)
    end

    # Like +element+, but string parameters are not escaped.
    def element!(*args, &block)
      __element__(true, *args, &block)
    end

    # Internal method used to emit a self-closing HTML/XML element, including
    # a tag name and optional attributes (passed in via the default hash).
    #
    # Using the arcane powers of Ruby, there are magic methods that call
    # +empty_element+ for all the standard HTML tags, like +img+, +br+, and so
    # forth. Look at the source of #empty_tags for the full list.
    # Unfortunately, this big mojo confuses rdoc, so we can't see each method
    # in this rdoc page, but trust us, they're there.
    #
    def empty_element(*args, &block)
      __empty_element__(*args, &block)
    end

    # Returns an HTML-escaped version of its parameter. Leaves the output
    # string untouched. This method is idempotent: h(h(text)) will not
    # double-escape text. This means that it is safe to do something like
    # text(h("2<4")) -- it will produce "2&lt;4", not "2&amp;lt;4".
    def h(content)
      if content.respond_to?(:html_safe?) && content.html_safe?
        content
      else
        raw(CGI.escapeHTML(content.to_s))
      end
    end

    # Emits an open tag, comprising '<', tag name, optional attributes, and '>'
    def open_tag(tag_name, attributes={})
      output.newline if newliney?(tag_name) && !output.at_line_start?
      output << raw("<#{tag_name}#{format_attributes(attributes)}>")
      output.indent
    end

    # Emits a close tag, consisting of '<', '/', tag name, and '>'
    def close_tag(tag_name)
      output.undent
      output << raw("</#{tag_name}>")
      if newliney?(tag_name)
        output.newline
      end
    end

    # Returns text which will *not* be HTML-escaped.
    def raw(value)
      RawString.new(value.to_s)
    end

    # Emits text.  If a string is passed in, it will be HTML-escaped. If the
    # result of calling methods such as raw is passed in, the HTML will not be
    # HTML-escaped again. If another kind of object is passed in, the result
    # of calling its to_s method will be treated as a string would be.
    #
    # You shouldn't pass a widget in to this method, as that will cause
    # performance problems (as well as being semantically goofy). Use the
    # #widget method instead.
    def text(value)
      if value.is_a? Widget
        widget value
      else
        output << h(value)
      end
      nil
    end

    # Emits text which will *not* be HTML-escaped. Same effect as text(raw(s))
    def text!(value)
      text raw(value)
    end

    alias rawtext text!

    # Returns a copy of value with spaces replaced by non-breaking space characters.
    # With no arguments, return a single non-breaking space.
    # The output uses the escaping format '&#160;' since that works
    # in both HTML and XML (as opposed to '&nbsp;' which only works in HTML).
    def nbsp(value = " ")
      raw(h(value).gsub(/ /,'&#160;'))
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

    # Emits an XML instruction, which looks like this: <?xml version=\"1.0\" encoding=\"UTF-8\"?>
    def instruct(attributes={:version => "1.0", :encoding => "UTF-8"})
      output << raw("<?xml#{format_sorted(sort_for_xml_declaration(attributes))}?>")
    end

    # Emits an HTML comment (&lt;!-- ... --&gt;) surrounding +text+ and/or the output of +block+.
    # see http://www.w3.org/TR/html4/intro/sgmltut.html#h-3.2.4
    #
    # If +text+ is an Internet Explorer conditional comment condition such as "[if IE]",
    # the output includes the opening condition and closing "[endif]". See
    # http://www.quirksmode.org/css/condcom.html
    #
    # Since "Authors should avoid putting two or more adjacent hyphens inside comments,"
    # we emit a warning if you do that.
    def comment(text = '', &block)
      puts "Warning: Authors should avoid putting two or more adjacent hyphens inside comments." if text =~ /--/

      conditional = text =~ /\[if .*\]/

      rawtext "<!--"
      rawtext text
      rawtext ">" if conditional

      if block
        rawtext "\n"
        block.call
        rawtext "\n"
      end

      rawtext "<![endif]" if conditional
      rawtext "-->\n"
    end

    # Emits a javascript block inside a +script+ tag, wrapped in CDATA
    # doohickeys like all the cool JS kids do.
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
      rawtext "\n// ]]>"
      output.append_newline # this forces a newline even if we're not in pretty mode

      close_tag 'script'
      rawtext "\n"
    end

    protected
    def __element__(raw, tag_name, *args, &block)
      if args.length > 2
        raise ArgumentError, "Cannot accept more than four arguments"
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
      begin
        if block && value
          raise ArgumentError, "You can't pass both a block and a value to #{tag_name} -- please choose one."
        end
        if block
          block.call
        elsif raw
          text! value
        else
          text value
        end
      ensure
        close_tag tag_name
      end
    end

    def __empty_element__(tag_name, attributes={})
      output << raw("<#{tag_name}#{format_attributes(attributes)} />")
      output.newline if newliney?(tag_name)
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
            value = value.flatten
            next if value.empty?
            value = value.join(' ')
          end
          results << "#{key}=\"#{h(value)}\""
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

    NON_NEWLINEY = {'i' => true, 'b' => true, 'small' => true,
      'img' => true, 'span' => true, 'a' => true,
      'input' => true, 'textarea' => true, 'button' => true, 'select' => true
    }

    def newliney?(tag_name)
      !NON_NEWLINEY.include?(tag_name)
    end
  end
end
