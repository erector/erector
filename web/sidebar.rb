class Sidebar < Erector::Widget
  def initialize(current_page = nil)
    super
    @current_page = current_page
  end

  def clickable_li(text, href)
    li :onclick => "document.location='#{href}'", :class => "clickable" do
      a text, :href => href
    end
  end

  def render

    div :class => "sidebar" do
      a :href => "index.html" do
        img :src => 'erector.jpg', :align => 'left'
      end

      br :clear => "all"

      h3 "Sections:"
      ul do
        clickable_li "Readme", 'index.html'
        clickable_li "User Guide", 'documentation.html'
        clickable_li "FAQ", 'faq.html'
        clickable_li "For Developers", 'developers.html'
      end

      hr

      h3 "Links:"
      ul do
        href = 'http://rubyforge.org/frs/?group_id=4797'
        li :class => 'clickable', :onclick => "document.location='#{href}'" do
          a('Download', :href => href)
          br
          span " (current version: #{Erector::VERSION})"
        end
        clickable_li 'Version History', "http://erector.rubyforge.org/svn/trunk/History.txt"
        clickable_li 'RDoc Documentation', 'rdoc'
        clickable_li 'RubyForge Project', 'http://rubyforge.org/projects/erector/'
        clickable_li 'Lighthouse Project', 'http://erector.lighthouseapp.com'
        clickable_li 'Subversion Repository', 'http://rubyforge.org/scm/?group_id=4797'
        clickable_li "erector-devel mailing list", "http://rubyforge.org/mailman/listinfo/erector-devel"
      end

      hr
      h3 "Supported by:"
      center do
        a :href => "http://www.pivotallabs.com" do
          img :src => "pivotal.gif", :width => 158, :height => 57, :alt => "Pivotal Labs"
        end
      end
    end
  end

end
