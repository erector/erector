class ActionWidgets::WrongClass::FallbackActionWidgetWithWrongClass < Erector::Widget
  def content
    text "action widget content #{@foobar}"
  end
end
