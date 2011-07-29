dir = File.dirname(__FILE__)
require "#{dir}/clickable_li"

class Sidebar < Erector::Widget
  
  def clickable_li(item, href)
    widget ClickableLi, :item => item, :href => href
  end
  
  def content
    
    div.sidebar do

      div.logo {
        center {
          a :href => "index.html" do
            img :src => 'erector.jpg', :class => 'logo', :height => (323*0.6).to_i, :width => (287*0.6).to_i
          end
        }
      }

      h3 "Documentation:"
      ul.clickable do
        clickable_li "README", 'index.html'
        clickable_li "User Guide", 'userguide.html'
        clickable_li "FAQ", 'faq.html'
        clickable_li 'RDoc API', 'rdoc'
        clickable_li "For Developers", 'developers.html'
        clickable_li "Release Notes", 'release_notes.html'
      end

      h3 "External Links:"
      ul.clickable do
        href = 'http://rubyforge.org/frs/?group_id=4797'
        li :class => 'clickable', :onclick => "document.location='#{href}'" do
          a('Download', :href => href)
          br
          span " (current version: #{Erector::VERSION})"
        end
        clickable_li 'Erector Mailing List', "http://googlegroups.com/group/erector"
        clickable_li 'RubyForge Project', 'http://rubyforge.org/projects/erector/'
        clickable_li 'Github Repository', 'http://github.com/pivotal/erector'
        clickable_li 'Tracker Project', 'http://www.pivotaltracker.com/projects/482'
        clickable_li "erector-devel archive", "http://rubyforge.org/pipermail/erector-devel/"
      end

    end
  end

end
