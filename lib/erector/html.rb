require "erector/element"
require "erector/attributes"
require "erector/promise"
require "erector/text"

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
              __element__('#{tag_name}', *args, &block)
          end

          def #{tag_name}!(*args, &block)
            __element__('#{tag_name}', *(args.map{|a|raw(a)}), &block)
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

    include Element
    include Attributes
    include Text

    # Emits an XML instruction, which looks like this: <?xml version=\"1.0\" encoding=\"UTF-8\"?>
    def instruct(attributes={:version => "1.0", :encoding => "UTF-8"})
      output << raw("<?xml#{format_sorted(sort_for_xml_declaration(attributes))}?>")
    end

    # Emits an HTML comment (&lt;!-- ... --&gt;) surrounding +text+ and/or the
    # output of +block+. see
    # http://www.w3.org/TR/html4/intro/sgmltut.html#h-3.2.4
    #
    # If +text+ is an Internet Explorer conditional comment condition such as
    # "[if IE]", the output includes the opening condition and closing
    # "[endif]". See http://www.quirksmode.org/css/condcom.html
    #
    # Since "Authors should avoid putting two or more adjacent hyphens inside
    # comments," we emit a warning if you do that.
    def comment(text = '')
      puts "Warning: Authors should avoid putting two or more adjacent hyphens inside comments." if text =~ /--/

      conditional = text =~ /\[if .*\]/

      rawtext "<!--"
      rawtext text
      rawtext ">" if conditional

      if block_given?
        rawtext "\n"
        yield
        rawtext "\n"
      end

      rawtext "<![endif]" if conditional
      rawtext "-->\n"
    end

    # Emits a javascript block inside a +script+ tag, wrapped in CDATA
    # doohickeys like all the cool JS kids do.
    def javascript(value = nil, attributes = {})
      if value.is_a?(Hash)
        attributes = value
        value      = nil
      elsif block_given? && value
        raise ArgumentError, "You can't pass both a block and a value to javascript -- please choose one."
      end

      script(attributes.merge(:type => "text/javascript")) do
        # Shouldn't this be a "cdata" HtmlPart?
        # (maybe, but the syntax is specific to javascript; it isn't
        # really a generic XML CDATA section.  Specifically,
        # ]]> within value is not treated as ending the
        # CDATA section by Firefox2 when parsing text/html,
        # although I guess we could refuse to generate ]]>
        # there, for the benefit of XML/XHTML parsers).
        output << raw("\n// <![CDATA[\n")
        if block_given?
          yield
        else
          output << raw(value)
        end
        output << raw("\n// ]]>")
        output.append_newline # this forces a newline even if we're not in pretty mode
      end

      output << raw("\n")
    end

    protected

    def sort_for_xml_declaration(attributes)
      # correct order is "version, encoding, standalone" (XML 1.0 section 2.8).
      # But we only try to put version before encoding for now.
      stringized = []
      attributes.each do |key, value|
        stringized << [key.to_s, value]
      end
      stringized.sort{|a, b| b <=> a}
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
