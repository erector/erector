class Views::Layouts::ErectorLayoutWithNestedWidget < Erector::Widget
  needs :layout_need => 'erector'
  
  def content
    render :widget => Views::Test::RenderDefault
    text 'nested in '
    rawtext content_for(:layout)
    text "with #{@layout_need} layout"
  end
end
