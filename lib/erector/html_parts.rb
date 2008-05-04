module Erector
  
  # An array to which is written a stream of HTML "parts" -- each part being an open tag, a string, a close tag, etc.
  class HtmlParts < Array
    def to_s
      map do |part|
        case part[:type].to_sym
        when :open
          part[:attributes] ?
            "<#{part[:tagName]}#{format_attributes(part[:attributes])}>" :
            "<#{part[:tagName]}>"
        when :close
          "</#{part[:tagName]}>"
        when :empty
          part[:attributes] ?
            "<#{part[:tagName]}#{format_attributes(part[:attributes])} />" :
            "<#{part[:tagName]}  />"
        when :text
          part[:value].html_escape
        when :instruct
          "<?xml#{format_sorted(sort_for_xml_declaration(part[:attributes]))}?>"
        end
      end.join
    end

    protected
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
