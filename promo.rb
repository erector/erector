class Promo < Erector::Widget
  needs :src
  
  def content
    div.promo_wrapper {
      div.promo {
        img :src => @src, :height => @height, :width => @width
      }
    }
  end
end

