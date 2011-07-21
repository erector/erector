module Erector
  module HTML

    # todo: move these tag methods to some parent class or module so we can
    # have different XML-ish document types

    @@tags = {}

    def self.tag *args
      tag = Tag.new(*args)
      @@tags[tag.name] = tag

      if tag.self_closing?
        self.class_eval(<<-SRC, __FILE__, __LINE__ + 1)
          def #{tag.name}(*args, &block)
            _empty_element('#{tag.name}', *args, &block)
          end
        SRC
      else
        self.class_eval(<<-SRC, __FILE__, __LINE__ + 1)
          def #{tag.name}(*args, &block)
              _element('#{tag.name}', *args, &block)
          end

          def #{tag.name}!(*args, &block)
            _element('#{tag.name}', *(args.map{|a|raw(a)}), &block)
          end
        SRC
      end
    end

    # Tags which are always self-closing
    def self.self_closing_tags
      @@tags.values.select{|tag| tag.self_closing?}.map{|tag| tag.name}
    end

    # Tags which can contain other stuff
    def self.full_tags
      @@tags.values.select{|tag| !tag.self_closing?}.map{|tag| tag.name}
    end

    tag 'area', :self_closing
    tag 'base', :self_closing
    tag 'br', :self_closing
    tag 'col', :self_closing
    tag 'embed', :self_closing
    tag 'frame', :self_closing
    tag 'hr', :self_closing
    tag 'img', :self_closing, :inline
    tag 'input', :self_closing, :inline
    tag 'link', :self_closing
    tag 'meta', :self_closing
    tag 'param', :self_closing

    tag 'a', :inline
    tag 'abbr'
    tag 'acronym'
    tag 'address'
    tag 'article'
    tag 'aside'
    tag 'audio'

    tag 'b', :inline
    tag 'bdo'
    tag 'big'
    tag 'blockquote'
    tag 'body'
    tag 'button', :inline

    tag 'canvas'
    tag 'caption'
    tag 'center'
    tag 'cite'
    tag 'code'
    tag 'colgroup'
    tag 'command'

    tag 'datalist'
    tag 'dd'
    tag 'del'
    tag 'details'
    tag 'dfn'
    tag 'dialog'
    tag 'div'
    tag 'dl'
    tag 'dt'

    tag 'em'

    tag 'fieldset'
    tag 'figure'
    tag 'footer'
    tag 'form'
    tag 'frameset'

    tag 'h1'
    tag 'h2'
    tag 'h3'
    tag 'h4'
    tag 'h5'
    tag 'h6'
    tag 'head'
    tag 'header'
    tag 'hgroup'
    tag 'html'
    tag 'i', :inline

    tag 'iframe'
    tag 'ins'
    tag 'keygen'
    tag 'kbd'
    tag 'label'
    tag 'legend'
    tag 'li'

    tag 'map'
    tag 'mark'
    tag 'meter'

    tag 'nav'
    tag 'noframes'
    tag 'noscript'

    tag 'object'
    tag 'ol'
    tag 'optgroup'
    tag 'option'

    tag 'p'
    tag 'pre'
    tag 'progress'

    tag 'q'
    tag 'ruby'
    tag 'rt'
    tag 'rp'
    tag 's'

    tag 'samp'
    tag 'script'
    tag 'section'
    tag 'select', :inline
    tag 'small', :inline
    tag 'source'
    tag 'span', :inline
    tag 'strike'

    tag 'strong'
    tag 'style'
    tag 'sub'
    tag 'sup'

    tag 'table'
    tag 'tbody'
    tag 'td'
    tag 'textarea', :inline
    tag 'tfoot'

    tag 'th'
    tag 'thead'
    tag 'time'
    tag 'title'
    tag 'tr'
    tag 'tt'

    tag 'u'
    tag 'ul'

    tag 'var'
    tag 'video'


    def newliney?(tag_name)
      tag = @@tags[tag_name]
      if tag
        tag.newliney?
      else
        true
      end
    end

    require "erector/element"
    require "erector/attributes"
    require "erector/promise"
    require "erector/text"
    require "erector/tag"


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

  end
end
