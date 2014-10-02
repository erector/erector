class Views::TestCaching::CacheableWidgetWithStaticKeys < Erector::Widget

  cacheable 'v1'

  def content
    text DateTime.now
  end

end
