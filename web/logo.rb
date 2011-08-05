class Logo < Erector::Widget
  def content
    div.logo {
      a :href => "index.html" do
        img.logo :src => 'erector.jpg',
          :height => 323, 
          :width => 287
      end
    }
  end
end
