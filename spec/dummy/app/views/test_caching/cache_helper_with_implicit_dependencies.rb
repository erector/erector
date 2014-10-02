class Views::TestCaching::CacheHelperWithImplicitDependencies < Erector::Widget

  def content
    render 'foos'
  end

end
