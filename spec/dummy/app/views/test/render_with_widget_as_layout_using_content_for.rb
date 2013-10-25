class Views::Test::RenderWithWidgetAsLayoutUsingContentFor < Erector::Widget
  def content
    content_for(:top) do
      text "TOP"
    end
    text @during || "DURING"
  end
end
