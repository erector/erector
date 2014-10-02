class Views::TestCaching::CacheHelperWithSkipDigest < Erector::Widget

  def content
    cache 'cache_helper_with_skip_digest_key', skip_digest: true do
      text DateTime.current
    end
  end

end
