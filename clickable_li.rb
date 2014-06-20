class ClickableLi < Erector::Widget
  needs :item, :href, :current => false

  def content
    classes = ["clickable"]
    classes << "current" if @current
    li :onclick => "document.location='#{@href}'", :class => classes do
      a @item, :href => @href
    end
  end
end

