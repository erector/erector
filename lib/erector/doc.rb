module Erector
  # A proxy to an IO object that adds methods to add xml. 
  class Doc
    attr_reader :doc
    def initialize(doc)
      @doc = doc
    end

    def open_tag(tag_name, attributes={})
      doc.print "<#{tag_name}#{format_attributes(attributes)}>"
    end

    def text(value)
      doc.print(value.html_escape)
      nil
    end

    def close_tag(tag_name)
      doc.print("</#{tag_name}>")
    end

    def empty_element(tag_name, attributes={})
      doc.print "<#{tag_name}#{format_attributes(attributes)} />"
    end

    def instruct(attributes={:version => "1.0", :encoding => "UTF-8"})
      doc.print "<?xml#{format_sorted(sort_for_xml_declaration(attributes))}?>"
    end

    def to_s
      doc.string
    end

    protected
    def method_missing(method_name, *args, &blk)
      if doc.respond_to?(method_name)
        doc.__send__(method_name, *args, &blk)
      else
        super
      end
    end

    def format_attributes(attributes)
      return "" if !attributes || attributes.empty?
      return format_sorted(sorted(attributes))
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
