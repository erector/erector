module Erector
  class HtmlParts < Array
    def to_s
      map do |part|
        case part['type']
        when 'open'
          part['attributes'] ?
            "<#{part['tagName']}#{format_attributes(part['attributes'])}>" :
            "<#{part['tagName']}>"
        when 'close'
          "</#{part['tagName']}>"
        when 'standalone'
          part['attributes'] ?
            "<#{part['tagName']}#{format_attributes(part['attributes'])} />" :
            "<#{part['tagName']}  />"
        when 'text'
          part['value'].to_s.html_escape
        when 'instruct'
          "<?xml#{format_attributes(part['attributes'])}?>"
        end
      end.join
    end

    protected
    def format_attributes(attributes)
      return "" if !attributes || attributes.empty?
      results = ['']
      attributes.each do |key, value|
        if value
          if value.is_a?(Array)
            value = [value].flatten.join(' ')
          end
          results << "#{key}=\"#{value.to_s.html_escape}\""
        end
      end
      results.join ' '
    end
  end  
end
