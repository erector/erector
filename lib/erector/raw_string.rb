module Erector
  # A string that has a special type so Erector knows to render it directly, not HTML-escaped
  class RawString < String
    def html_safe?
      true
    end

    def to_s
      self
    end
  end
end
