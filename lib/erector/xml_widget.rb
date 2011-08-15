require 'erector/abstract_widget'
require 'erector/tag'
require 'erector/needs'

module Erector

  # Abstract base class for XML Widgets and HTMLWidget.
  # Declares "tags" which define methods that emit tags.
  class XMLWidget < AbstractWidget
    include Needs

    def self.tag_named tag_name, checked = []
      @tags ||= {}
      @tags[tag_name] || begin
        tag = nil
        checked << self
        taggy_ancestors = (ancestors - checked).select{|k| k.respond_to? :tag_named}
        taggy_ancestors.each do |k|
          tag = k.tag_named(tag_name, checked)
          if tag
            @tags[tag_name] = tag
            break
          end
        end
        tag
      end
    end

    def self.tag *args
      tag = Tag.new(*args)
      @tags ||= {}
      @tags[tag.name] = tag

      if instance_methods.include?(tag.method_name.to_sym)
        warn "method '#{tag.method_name}' is already defined; skipping #{caller[1]}"
        return
      end

      if tag.self_closing?
        self.class_eval(<<-SRC, __FILE__, __LINE__ + 1)
          def #{tag.method_name}(*args, &block)
            _empty_element('#{tag.name}', *args, &block)
          end
        SRC
      else
        self.class_eval(<<-SRC, __FILE__, __LINE__ + 1)
        def #{tag.method_name}(*args, &block)
              _element('#{tag.name}', *args, &block)
          end

          def #{tag.method_name}!(*args, &block)
            _element('#{tag.name}', *(args.map{|a|raw(a)}), &block)
          end
        SRC
      end
    end

    # Tags which are always self-closing
    def self.self_closing_tags
      @tags.values.select{|tag| tag.self_closing?}.map{|tag| tag.name}
    end

    # Tags which can contain other stuff
    def self.full_tags
      @tags.values.select{|tag| !tag.self_closing?}.map{|tag| tag.name}
    end

    def newliney?(tag_name)
      tag = self.class.tag_named tag_name
      if tag
        tag.newliney?
      else
        true
      end
    end

    # Emits an XML instruction, which looks like this: <?xml version=\"1.0\" encoding=\"UTF-8\" ?>
    def instruct(attributes={:version => "1.0", :encoding => "UTF-8"})
      output << raw("<?xml#{format_sorted(sort_for_xml_declaration(attributes))}?>")
    end

    # Emits an XML/HTML comment (&lt;!-- ... --&gt;) surrounding +text+ and/or
    # the output of +block+. see
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

    alias_method :to_xml, :emit

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

  public

  XmlWidget = XMLWidget

end
