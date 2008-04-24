dir = File.dirname(__FILE__)
require "#{dir}/page"

class Index < Page
  def initialize
    super
    @title = "Erector"
  end
  
  def render_body
    style do
      text 'img { margin-right: 3em; }'
    end
    img :src => 'erector.jpg', :align => 'left'
    h1 do
      text 'Erector'
    end
    
    h2 "Erector Links:"
    ul do
      li do
        a :href => 'rdoc' do
          text 'RDoc Documentation'
        end
      end
      li do
        a :href => 'http://rubyforge.org/projects/erector/' do
          text 'RubyForge Project'
        end
      end
      li do
        a :href => 'http://rubyforge.org/scm/?group_id=4797' do
          text 'Subversion'
        end
      end
      li do
        a :href => 'http://rubyforge.org/frs/?group_id=4797' do
          text 'Download'
        end
        span " (current version: #{Erector::VERSION})"
      end
      li do
        a "erector-devel mailing list", :href => "http://rubyforge.org/mailman/listinfo/erector-devel"
      end
    end
    br :clear => "all"
    pre do
      text File.read("#{File.dirname(__FILE__)}/../README.txt")
    end
  end
end
