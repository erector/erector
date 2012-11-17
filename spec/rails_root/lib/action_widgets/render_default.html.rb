# this should never display if ActionWidgets is handled with fallback ActionWidgetLibraryResolver
class ActionWidgets::RenderDefault < Erector::Widget
  def content
    text "action widget default #{@foobar}"
  end
end
