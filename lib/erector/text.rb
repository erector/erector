require "erector/raw_string"

module Erector
  module Text
    # Emits text to the output buffer, e.g.
    #
    #   text "my dog smells awful"
    #   => "my dog smells awful"
    #
    # If a string is passed in, it will be HTML-escaped. If the
    # result of calling methods such as raw is passed in, the HTML will not be
    # HTML-escaped again. If another kind of object is passed in, the result
    # of calling its to_s method will be treated as a string would be.
    #
    # You shouldn't pass a widget in to this method, as that will cause
    # performance problems (as well as being semantically goofy). Use the
    # #widget method instead.
    #
    # You may pass a series of values (i.e. varargs). In that case, each value
    # will be emitted to the output stream in turn. You can specify a delimiter
    # by using an options hash with as the final argument, using +:join+ as the key,
    # e.g.
    # 
    #   text "my", "dog", "smells", :join => " "
    #   => "my dog smells"
    #
    # You may also pass a Promise as a parameter; every tag
    # method now returns a Promise after emitting. This allows
    # you to easily embed simple HTML formatting into a sentence, e.g.
    #
    #   text "my", "dog", "smells", b("great!"), :join => " "
    #   => "my dog smells <b>great!</b>"
    #
    # (Yes, the initial call to +b+ emits "\&lt;b>great\&lt;/b>" to the output buffer;
    # the Promise feature takes care of rewinding and rewriting the output
    # buffer during the later call to +text+.)
    #
    def text(*values)
      options = if values.last.is_a? Hash
        values.pop
      else
        {}
      end
      delimiter = options[:join]

      values.select{|value| value.is_a? Promise}.each do |promise|
        # erase whatever the promises wrote already
        promise._rewind
      end

      first = true
      values.each do |value|
        if !first and delimiter
          output << h(delimiter)
        end
        first = false

        case value
        when AbstractWidget
          # todo: better deprecation
          raise "Don't pass a widget to the text method. Use the widget method instead."
        when Promise
          value._mark # so the promise's rewind won't erase anything
          value._render # render the promise to the output stream again
          # note: we could let the promise cache its first effort, but
          # here I think it's better to optimize for memory over speed
        else
          output << h(value)
        end
      end
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
