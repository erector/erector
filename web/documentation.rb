dir = File.dirname(__FILE__)
require "#{dir}/page"
require "#{dir}/sidebar"

class Documentation < Page
  def render_body

    p do
      text "Make sure to check out the "
      a "RDoc Documentation", :href => "rdoc"
      text " for more details on the API."
    end

    h2 "Contents:"
    ul do
      sections.each do |section|
        li do
          a section.title, :href => "##{section.href}"
        end
      end
    end

    sections.each do |section|
      a :name => section.href
      h2 section.title
      section.render_to(doc)
    end
  end

  def sections
  [
    Section.new("The Basics") do
      p "The basic way to construct some HTML/XML with erector is to subclass Erector::Widget and implement a render method:"
      table do
        tr do 
          td do
            pre <<DONE
class Hello < Erector::Widget
  def render
    html do
      head do
        title "Hello"
      end
      body do
        text "Hello, "
        b "world!"
      end
    end
  end
end
DONE
          end
          td do
            span :class => "separator" do
              text "=>"
            end
          end
          td do
            pre <<DONE
<html>
  <head>
    <title>Hello</title>
  </head>
  <body>
  Hello, <b>world!</b>
  </body>
</html>
DONE
          end
        end
      end
    end,

    Section.new("API Cheatsheet") do
      pre <<DONE
element('foo')           # <foo></foo>
empty_element('foo')     # <foo />
html                     # <html></html> (likewise for other common html tags)
b 'foo'                  # <b>foo</b>
text 'foo'               # foo
text '&<>'               # &amp;&lt;&gt; (what you generally want, especially
                         # if the text came from the user or a database)
text raw('&<>')          # &<> (back door for raw html)
rawtext('&<>')           # &<> (alias for text(raw()))
html { text 'foo' }      # <html>foo</html>
html 'foo'               # <html>foo</html>
html foo                 # <html>bar</html> (if the method foo returns the string \"bar\")
a(:href => 'foo.html')   # <a href=\"foo.html\"></a>
a(:href => 'q?a&b')      # <a href=\"q?a&amp;b\"></a>  (quotes as for text)
a(:href => raw('&amp;')) # <a href=\"&amp;\"></a>
a 'foo', :href => "bar"  # <a href=\"bar\">foo</a>
text nbsp('Save Doc')    # Save&#160;Doc (turns spaces into non-breaking spaces)
instruct                 # <?xml version=\"1.0\" encoding=\"UTF-8\"?>

javascript('if (x < y && x > z) alert("don\\\'t stop");') #=>
<script type="text/javascript">
// <![CDATA[
if (x < y && x > z) alert("don't stop");
// ]]>
</script>
DONE
      i "TODO: document more obscure features like capture, Table, :class => ['one', 'two']"
    end,

    Section.new("Using Erector from Ruby on Rails") do

      p do
        text "Your views are just ruby classes.  Your controller can either call Rails' "
        code "render :template"
        text " method as usual, or directly instantiate the view class and call its render method."
      end
      
      p "For example:"

      code "app/controllers/welcome_controller.rb:"
      pre <<DONE
class WelcomeController < ApplicationController
  def index
    render :template => 'welcome/show'
  end
end
DONE

      code "app/views/welcome/show.rb:"
      pre <<DONE
class Views::Welcome::Show < Erector::Widget
  def render
    html do
      head do
        title "Welcome page"
      end
      body do
        p "Hello, world"
      end
    end
  end
end
DONE

      p do
        text "For Rails to find these .rb files during "
        code "render :template"
        text ", you must first either copy the erector source to "
        code "vendor/plugins/erector"
        text ", or add "
        code "require 'erector'"
        text " to "
        code "config/environment.rb"
        text ". You also should delete (or rename) any other view files with the same base name that might be getting in the way."
      end

    end,

    Section.new("Erect: Command-line conversion to and from HTML") do

      p <<DONE
      To make Rails integration as smooth as possible, we've written a little tool that will help you
      erect your existing Rails app. The "erect" tool will convert HTML or HTML/ERB into an Erector class.
      It ships as part of the Erector gem, so to try it out, install the gem, then run
DONE
      pre "erect app/views/foos/*.html.erb"

      p "or just"

      pre "erect app/views"

      p "and then delete the original files when you're satisfied."

      p "Here's a little command-line howto for erecting a scaffold Rails app:"

      pre <<DONE
rails foo
cd foo
script/generate scaffold post title:string body:text published:boolean

erect app/views/posts

mate app/views/posts
sleep 30 # this should be enough time for you to stop drooling
rm app/views/posts/*.erb
(echo ""; echo "require 'erector'") >> config/environment.rb
rake db:migrate
script/server
open http://localhost:3000/posts
DONE
        
    end,


    Section.new("Layout Inheritance") do
      p "Erector replaces the typical Rails layout mechanism with a more natural construct, the use of inheritance. Want a common
      layout? Just implement a layout superclass and inherit from it. Implement render in the superclass and implement template
      methods in its subclasses. There's one trick you'll need to use this layout for non-erector templates. Here's an example."

      p do
        code "application.rb"
        text " - The Erector layout superclass"
        pre <<DONE
class Views::Layouts::Application < Erector::Widget
  attr_accessor :content

  def render
    html do
      head { } # head content here
      # body content here
      body do
        text content
      end
    end
  end
end
DONE
      end

      p do
        code "application.mab"
        text " - The markaby template (adjust for other appropriately templating technologies)"
        pre <<DONE
widget = Views::Layouts::Application.new(self)
widget.content = content_for_layout
self << widget.to_s
DONE
      end

      p do
        text "Here the abstract layout widget is used in a concrete fashion by the template-based layout. Normally, the "
        code "content"
        text " method would be implemented by subclassing widgets, but the layout template sets it directly and then calls "
        code "to_s"
        text " on the layout widget. This allows the same layout to be shared in a backward compatible way."
      end
    end,


    Section.new("Inline Widgets") do
      p do
        text "Instead of subclassing "
        code "Erector::Widget"
        text " and implementing a render method, you can pass a block to "
        code "Erector::Widget.new"
        text ".  For example:"
        pre <<DONE
html = Erector::Widget.new do
  p "Hello, world!"
end
html.to_s          #=> <p>Hello, world!</p>
DONE
        text "This lets you define mini-widgets on the fly."
      end
    end,

    
    ]
  end
end

class Section < Erector::Widget
  attr_reader :title

  def initialize(title, &block)
    super(&block)
    @title = title
  end

  def href
    title.split(':').first.gsub(/[^\w]/, '').downcase
  end
end
