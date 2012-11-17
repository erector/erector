# this should never display if ActionWidgets is handled with fallback ActionWidgetLibraryResolver
class ActionWidgets::Test::RenderDefault < Erector::Widget
  def content
    text "action widget default #{@foobar}"
  end
end
