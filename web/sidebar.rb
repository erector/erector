class Sidebar < Erector::Widget
  def initialize(current_page = nil)
    super
    @current_page = current_page
  end

  def render

    div :class => "sidebar" do

      img :src => 'erector.jpg', :align => 'left'

      br :clear => "all"

      h3 "Sections:"
      ul do
        li { a "Readme", :href => 'index.html' }
        li { a "User Guide", :href => 'documentation.html' }
        li { a "Motivation", :href => 'motivation.html' }
        li { a "For Developers", :href => 'developers.html' }
      end

      hr

      h3 "Links:"
      ul do
        li do
          a('Download', :href => 'http://rubyforge.org/frs/?group_id=4797')
          br
          span " (current version: #{Erector::VERSION})"
        end
        li { a('RDoc Documentation', :href =>'rdoc') }
        li { a('RubyForge Project', :href => 'http://rubyforge.org/projects/erector/') }
        li { a('Subversion Repository', :href => 'http://rubyforge.org/scm/?group_id=4797') }
        li { a("erector-devel mailing list", :href => "http://rubyforge.org/mailman/listinfo/erector-devel") }
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
