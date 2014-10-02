class Views::TestCaching::CacheableWidgetWithNeedsKeys < Erector::Widget

  needs :person, :food, beer: 'beer'

  cacheable needs_keys: [:person, :beer]

  def content
    text DateTime.current
  end

end
