module ViewCaching
  def self.included(mod)
    mod.extend ClassMethods
  end
  module ClassMethods
    def view_cache
      @view_cache ||= {}
    end
  end

  def view_cache(&blk)
    cache = self.class.view_cache
    if cache.empty?
      cache[:body] = @body = yield
      cache[:doc] = @doc = Hpricot(@body)
    else
      @body = cache[:body]
      @doc = cache[:doc]
    end
  end

  def doc
    @doc
  end

  def body
    @body
  end
  alias_method :html, :body
end