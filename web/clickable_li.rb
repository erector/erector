class ClickableLi < Erector::Widget
  needs :item, :href
  def content
    li :onclick => "document.location='#{@href}'", :class => "clickable" do
      a @item, :href => @href
    end
  end
end

