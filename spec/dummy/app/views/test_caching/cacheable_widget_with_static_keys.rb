class Views::TestCaching::CacheableWidgetWithStaticKeys < Erector::Widget

  cacheable 'v1'

  def content
    text DateTime.current
  end

end
