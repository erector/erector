dir = File.dirname(__FILE__)
require "#{dir}/page"
require "#{dir}/sidebar"

require "rdoc/rdoc"

require 'rdoc/markup/simple_markup'
require 'rdoc/markup/simple_markup/to_html'

class Index < Page
  def initialize
    super("Home")
  end

  def render_body

    h2 "Links:"
    ul do
      li do
        a('Download', :href => 'http://rubyforge.org/frs/?group_id=4797')
        span " (current version: #{Erector::VERSION})"
      end
      li { a('RDoc Documentation', :href =>'rdoc') }
      li { a('RubyForge Project', :href => 'http://rubyforge.org/projects/erector/') }
      li { a('Subversion Repository', :href => 'http://rubyforge.org/scm/?group_id=4797') }
      li { a("erector-devel mailing list", :href => "http://rubyforge.org/mailman/listinfo/erector-devel") }
    end

    hr
    h1 "Readme"

    readme = File.read("#{File.dirname(__FILE__)}/../README.txt")
    readme.gsub!(/^\= Erector/, '')
    p = SM::SimpleMarkup.new
    h = SM::ToHtml.new

    rawtext p.convert(readme, h)

  end
end

