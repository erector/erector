dir = File.dirname(__FILE__)
require "#{dir}/page"
require "#{dir}/navbar"

class Community < Page
  def initialize
    super(:page_title => "Community")
  end

  def body_content
    ul.clickable do
      clickable_li 'Erector Mailing List', "http://googlegroups.com/group/erector"
      clickable_li 'Github Repository', 'http://github.com/erector/erector'
      clickable_li 'Tracker Project', 'http://www.pivotaltracker.com/projects/482'
    end

  end
end
