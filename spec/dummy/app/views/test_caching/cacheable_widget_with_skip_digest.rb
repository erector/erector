class Views::TestCaching::CacheableWidgetWithSkipDigest < Erector::Widget

  cacheable skip_digest: true

  def content
    text DateTime.current
  end

end
