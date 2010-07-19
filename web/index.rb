dir = File.dirname(__FILE__)
require "#{dir}/page"
require "#{dir}/sidebar"

require "rubygems"
require "bundler"
Bundler.setup
require 'rdoc/markup'
require 'rdoc/markup/to_html'

class Index < Page
  def initialize
    super(:page_title => "Home")
  end

  def readme
    text = File.read("#{File.dirname(__FILE__)}/../README.txt")
    text.gsub!(/^\= Erector/, '')
    text = RDoc::Markup::ToHtml.new.convert(text)
    text.gsub!(/Erector::Widget/, capture { a "Erector::Widget", :href=> "rdoc/classes/Erector/Widget.html" }.strip)
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

