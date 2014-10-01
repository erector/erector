class Views::TestCaching::CacheableWidgetWithNeeds < Erector::Widget

  needs :person, :food

  cacheable

  def content
    text DateTime.now
  end

end
