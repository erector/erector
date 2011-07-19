
module Erector
  module Text
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
        # todo: better deprecation
        raise "Don't pass a widget to the text method. Use the widget method instead."
      end
      output << h(value)
      nil
    end

    # Returns text which will *not* be HTML-escaped.
    def raw(value)
      RawString.new(value.to_s)
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

    # Return a character given its unicode code point or unicode name.
    def character(code_point_or_name)
      if code_point_or_name.is_a?(Symbol)
        require "erector/unicode"
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

  end
end
