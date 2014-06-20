dir = File.dirname(__FILE__)
require "#{dir}/clickable_li"

class Navbar < Erector::Widget
  needs :current_page
  
  def clickable_li(item, href, current = false)
    widget ClickableLi, :item => item, :href => href, :current => current
  end
  
  def clickable_page page
    clickable_li page.display_name, page.href, page.class == @current_page.class
  end
  
  def content
    dir = File.dirname(__FILE__)
    Dir.glob("#{dir}/*.rb").each {|f| require f.gsub(/\.rb$/, '')}
    div.navbar do
      ul.clickable do
        clickable_page Index.new
        clickable_page Userguide.new
        clickable_page Rails.new
        clickable_page Faq.new
        clickable_page Cheatsheet.new
        clickable_li 'RDoc API', 'rdoc'
        clickable_page Developers.new
        clickable_page ReleaseNotes.new
        clickable_page Community.new
      end
    end
  end

end
