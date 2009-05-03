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

    h1 "Readme"

    readme = File.read("#{File.dirname(__FILE__)}/../README.txt")
    readme.gsub!(/^\= Erector/, '')
    p = SM::SimpleMarkup.new
    h = SM::ToHtml.new

    rawtext p.convert(readme, h)

  end
end

