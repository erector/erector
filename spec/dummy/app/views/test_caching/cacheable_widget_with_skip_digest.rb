class Views::TestCaching::CacheableWidgetWithSkipDigest < Erector::Widget

  cacheable skip_digest: true

  def content
    text DateTime.now
  end

end
