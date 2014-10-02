class Views::TestCaching::CacheHelperWithPartial < Erector::Widget

  def content
    cache 'cache_helper_with_partial_key' do
      text DateTime.current
      render 'partial'
    end
  end

end
