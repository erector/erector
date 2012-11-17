class ActionWidgets::FallbackActionWidget < Erector::Widget
  def content
    text "action widget content #{@foobar}"
  end
end
