dir = File.dirname(__FILE__)
require "#{dir}/page"
require "#{dir}/sidebar"

require "rdoc/rdoc"

require 'rdoc/markup/simple_markup'
require 'rdoc/markup/simple_markup/to_html'

class Index < Page
  def initialize
    super(:page_title => "Home")
  end

  def render_body

    readme = File.read("#{File.dirname(__FILE__)}/../README.txt")
    readme.gsub!(/^\= Erector/, '')
    p = SM::SimpleMarkup.new
    h = SM::ToHtml.new
    readme = p.convert(readme, h)
    readme.gsub!(/Erector::Widget/, capture{a "Erector::Widget", :href=> "rdoc/classes/Erector/Widget.html"}.strip)
    readme.gsub!(/\b(http:\/\/|mailto:)([\w\.\/@])*\b/) do |match|
      capture{ url match }
    end
    rawtext readme
    hr
    p do
      text "Don't forget to read the "
      a "User Guide", :href => "userguide.html"
      text " and "
      a "FAQ", :href => "faq.html"
    end
  end
end

