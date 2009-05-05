class Sidebar < Erector::Widget
  needs :current_page => nil
  
  def clickable_li(text, href)
    li :onclick => "document.location='#{href}'", :class => "clickable" do
      a text, :href => href
    end
  end

  def content

    div :class => "sidebar" do
      a :href => "index.html" do
        img :src => 'erector.jpg', :align => 'left'
      end

      br :clear => "all"

      h3 "On This Site:"
      ul do
        clickable_li "Readme", 'index.html'
        clickable_li "User Guide", 'userguide.html'
        clickable_li "FAQ", 'faq.html'
        clickable_li "For Developers", 'developers.html'
      end

      hr

      h3 "External Links:"
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
        clickable_li 'Github Repository', 'http://github.com/pivotal/erector'
        clickable_li 'Tracker Project', 'http://www.pivotaltracker.com/projects/482'
        clickable_li 'Google Groups Mailing List', "http://googlegroups.com/group/erector"
        clickable_li "erector-devel Mailing List (archive)", "http://rubyforge.org/pipermail/erector-devel/"
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
