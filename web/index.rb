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

  def readme
    text = File.read("#{File.dirname(__FILE__)}/../README.txt")
    text.gsub!(/^\= Erector/, '')
    p = SM::SimpleMarkup.new
    h = SM::ToHtml.new
    text = p.convert(text, h)
    text.gsub!(/Erector::Widget/, capture { a "Erector::Widget", :href=> "rdoc/classes/Erector/Widget.html" }.strip)
    text.gsub!(/\b(http:\/\/|mailto:)([\w\.\/@])*\b/) do |match|
      capture { url match }
    end
    return text
  end

  def render_body
    rawtext readme
    hr
    p do
      text "Don't forget to read the "
      a "User Guide", :href => "userguide.html"
      text " and "
      a "FAQ", :href => "faq.html"
      text " and "
      a "API", :href => "rdoc"
    end
  end
end

