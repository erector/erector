class Views::TestCaching::CacheHelper < Erector::Widget

  def content
    cache 'cache_helper_key' do
      text DateTime.current
    end
  end

end
