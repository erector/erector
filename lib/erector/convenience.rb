module Erector
  module Convenience
    # Render (like to_html) but adding newlines and indentation.
    # You may just want to call to_html(:prettyprint => true)
    # so you can pass in other rendering options as well.
    def to_pretty(options = {})
      to_html(options.merge(:prettyprint => true))
    end

    # Render (like to_html) but stripping all tags and inserting some
    # appropriate formatting. Currently we format p, br, ol, ul, and li
    # tags.
    def to_text(options = {})
      # TODO: make text output a first class rendering strategy, like HTML is now,
      # so we can do things like nested lists and numbered lists
      html = to_html(options.merge(:prettyprint => false))
      html.gsub!(/^<p[^>]*>/m, '')
      html.gsub!(/(<(ul|ol)>)?<li>/, "\n* ")
      html.gsub!(/<(\/?(ul|ol|p|br))[^>]*( \/)?>/, "\n")
      CGI.unescapeHTML(html.gsub(/<[^>]*>/, ''))
    end

    # Emits the result of joining the elements in array with the separator.
    # The array elements and separator can be Erector::Widget objects,
    # which are rendered, or strings, which are html-escaped and output.
    def join(array, separator)
      first = true
      array.each do |widget_or_text|
        if !first
          text separator
        end
        first = false
        text widget_or_text
      end
    end

    # Convenience method to emit a css file link, which looks like this:
    # <link href="erector.css" rel="stylesheet" type="text/css" />
    # The parameter is the full contents of the href attribute, including any ".css" extension.
    #
    # If you want to emit raw CSS inline, use the #style method instead.
    def css(href, options = {})
      link({:rel => 'stylesheet', :type => 'text/css', :href => href}.merge(options))
    end

    # Convenience method to emit an anchor tag whose href and text are the same,
    # e.g. <a href="http://example.com">http://example.com</a>
    def url(href, options = {})
      a href, ({:href => href}.merge(options))
    end

    # makes a unique id based on the widget's class name and object id
    # that you can use as the HTML id of an emitted element
    def dom_id
      "#{self.class.name.gsub(/:+/,"_")}_#{self.object_id}"
    end
  end
end
