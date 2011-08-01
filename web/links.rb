dir = File.dirname(__FILE__)
require "#{dir}/page"
require "#{dir}/navbar"

class Links < Page
  def initialize
    super(:page_title => "Links")
  end

  def body_content
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
