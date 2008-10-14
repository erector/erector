class Object
  def metaclass
    class << self; self; end
  end

  def html_escape
    return CGI.escapeHTML(to_s)
  end

  def html_unescape
    CGI.unescapeHTML(to_s)
  end

  def escape_single_quotes
    self.gsub(/[']/, '\\\\\'')
  end
end

