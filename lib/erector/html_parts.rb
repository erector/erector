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
          part['value'].to_s
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
        results << "#{key}=#{value.to_s.inspect}" if value
      end
      results.join ' '
    end
  end  
end