class Sidebar < Erector::Widget
  def initialize(current_page = nil)
    super
    @current_page = current_page
  end

  def render

    div :class => "sidebar" do

      img :src => 'erector.jpg', :align => 'left'
      br :clear => "all"
      ul do
        li { a "Home", :href => 'index.html' }
        li { a "Motivation", :href => 'motivation.html' }
        li { a "Documentation", :href => 'documentation.html' }
        li { a "Developers", :href => 'developers.html' }
      end

      10.times { br }
      center do
        p "Supported by "
        a :href => "http://www.pivotallabs.com" do
          img :src => "pivotal.gif", :width => 158, :height => 57, :alt => "Pivotal Labs"
        end
      end
    end
  end

end
