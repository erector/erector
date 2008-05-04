module Erector
  # A string that has a special type so Erector knows to render it directly, not HTML-escaped
  class RawString < String
    def html_escape
      self
    end
  end
end
