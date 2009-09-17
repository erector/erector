dir = File.dirname(__FILE__)
require "#{dir}/page"
require "#{dir}/sidebar"
require "#{dir}/article"
require "#{dir}/section"

class Userguide < Page
  def initialize
    super(:page_title => "User Guide")
  end
  
  def render_body
    p do
      text "Make sure to check out the "
      a "RDoc Documentation", :href => "rdoc"
      text " for more details on the API."
    end

    widget article
  end

  def article
    Article.new(
  [
    Section.new("The Basics") do
      p "The basic way to construct some HTML/XML with erector is to subclass Erector::Widget and implement a content method:"
      table do
        tr do 
          td do
            pre <<DONE
class Hello < Erector::Widget
  def content
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
              text character(:rightwards_arrow)
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
      
      p do
        text "Once you have a widget class, you can instantiate it and then call its "
        code "to_s"
        text " method."
        text " If you want to pass in 'locals' (aka 'assigns'), then do so in the constructor's default hash. This will make instance variables of the same name, with Ruby's '@' sign."
      end
      pre <<-PRE
class Email < Erector::Widget
  def content
    a @address, :href => "mailto:#{@address}"
  end
end

>> Email.new(:address => "foo@example.com").to_s
=> "<a href=\"mailto:foo@example.com\">foo@example.com</a>"
      PRE
      p do
        text "(If you want control over which locals are valid to be passed in to a widget, use the "
        a "needs", :href => "#needs"
        text " macro.)"
      end
    end,

    Section.new("Mixin") do
      p "If all this widget stuff is too complicated, just do "
      pre "include Erector::Widget"
      p do
        text "and then call "
        code "erector { }"
        text " from anywhere in your code. It will make an "
        a "inline widget", :href => "#inline"
        text " for you, pass in the block, and call "
        code "to_s"
        text " on it. And if you pass any options to "
        code "erector"
        text ", like "
        code ":prettyprint => true"
        text ", it'll pass them along to "
        code "to_s"
        text "!"
      end
      h3 "Examples:"
      pre <<-PRE
erector { a "lols", :href => "http://icanhascheezburger.com/" }
=> "<a href=\\"http://icanhascheezburger.com/\\">lols</a>"

erector(:prettyprint => true) do
  ol do
    li "bacon"
    li "lettuce"
    li "tomato"
  end
end
=> "<ol>\\n  <li>bacon</li>\\n  <li>lettuce</li>\\n  <li>tomato</li>\\n</ol>\\n" 
      PRE

    end,

    Section.new("API Cheatsheet") do
      cheats = [
        ["element('foo')",             "<foo></foo>"],
        ["empty_element('foo')",       "<foo />"],
        ["html",                       "<html></html>", "and likewise for all non-deprecated elements from the HTML 4.0.1 spec"],
        ["b 'foo'",                    "<b>foo</b>"],
        ["div { b 'foo' }",            "<div><b>foo</b></div>"],

        ["text 'foo'",                 "foo"],
        ["text '&<>'",                 "&amp;&lt;&gt;", "all normal text is HTML escaped, which is what you generally want, especially if the text came from the user or a database"],
        ["text raw('&<>')",            "&<>", "raw text escapes being escaped"],
        ["rawtext('&<>')",             "&<>", "alias for text(raw())"],

        ["div { text 'foo' }",        "<div>foo</div>"],
        ["div 'foo'",                 "<div>foo</div>"],
        ["foo = 'bar'\ndiv foo",      "<div>bar</div>"],
        ["a(:href => 'foo.div')",     "<a href=\"foo.div\"></a>"],
        ["a(:href => 'q?a&b')",        "<a href=\"q?a&amp;b\"></a>", "attributes are escaped like text is"],
        ["a(:href => raw('&amp;'))",   "<a href=\"&amp;\"></a>", "raw strings are never escaped, even in attributes"],
        ["a 'foo', :href => \"bar\"",    "<a href=\"bar\">foo</a>"],

        ["text nbsp('Save Doc')",      "Save&#160;Doc", "turns spaces into non-breaking spaces"],
        ["text nbsp",                  "&#160;", "a single non-breaking space"],
        ["text character(160)",        "&#xa0;", "output a character given its unicode code point"],
        ["text character(:right-arrow)",      "&#x2192;", "output a character given its unicode name"],

        ["instruct",                   "<?xml version=\"1.0\" encoding=\"UTF-8\"?>"],
        ["url 'http://example.com'",   "<a href=\"http://example.com\">http://example.com</a>"],
        
        ["capture { div }", "<div></div>", "returns the block as a string, doesn't add it to the current output stream"],
        ["div :class => ['a', 'b']", "<div class=\"a b\"></div>"],
      ]
      cheats << [
        "javascript(\n'if (x < y && x > z) \nalert(\"don\\\'t stop\");')",
<<-DONE
<script type="text/javascript">
// <![CDATA[
if (x < y && x > z) alert("don't stop");
// ]]>
</script>
DONE
      ];
      
      cheats << ["join([widget1, widget2],\n separator)", "", "See examples/join.rb for more explanation"]
      
      table :class => 'cheatsheet' do
        tr do
          th "code"
          th "output"
        end
        cheats.each do |cheat|
          tr do
            td :width=>"30%" do
              code do
                join cheat[0].split("\n"), raw("<br/>")
              end
            end
            td do
              if cheat[1]
                code do
                  join cheat[1].split("\n"), raw("<br/>")
                end
              end
              if cheat[2]
                text nbsp("  ")
                text character(:horizontal_ellipsis)
                i cheat[2] 
              end
            end
          end
        end
      end
      
      p do
        text "Lots more documentation is at the "
        a "RDoc API pages", :href => "rdoc/index.html"
        text " especially for "
        a "Erector::Widget", :href => "rdoc/classes/Erector/Widget.html"
        text " so don't go saying we never wrote you nothin'."
      end
    end,
    
    Section.new("Pretty-printing") do
      p "Erector has the ability to insert newlines and indentation to make the generated HTML more readable.  Newlines are inserted before and after certain tags."
      p "To enable pretty-printing (insertion of newlines and indentation) of Erector's output, do one of the following:"
      ul do
        li do
          text "call "
          code "to_pretty"
          text " instead of "
          code "to_s"
          text " on your Erector::Widget"
        end
        li do
          text "pass "
          code ":prettyprint => true"
          text " to "
          code "to_s"
        end
        li do
          text "call "
          code "enable_prettyprint(true)"
          text " on your Erector::Widget.  Then subsequent calls to to_s will prettyprint"
        end
        li do
          text "call "
          code "Erector::Doc.prettyprint_default = true"
          text " (for example, in environments/development.rb in a rails application, or anywhere which is convenient)"
        end
      end
    end,

    Section.new("Using Erector from Ruby on Rails", "rails") do

      p do
        text "Your views are just ruby classes.  Your controller can either call Rails' "
        code "render :template"
        text " method as usual, or directly instantiate the view class and call its content method."
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
  def content
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
      
      p do
        text "Currently there is only partial support for some standard Rails features like partials, layouts, assigns, and helpers. Check the "
        a "erector Google Groups mailing list", :href => "http://googlegroups.com/group/erector"
        text " for status updates on these features."
      end

    end,

    Section.new("Erector tool: Command-line conversion to and from HTML", "tool") do

      p """
      To make Rails integration as smooth as possible, we've written a little tool that will help you
      erect your existing Rails app. The 'erector' tool will convert HTML or HTML/ERB into an Erector class.
      It ships as part of the Erector gem, so to try it out, install the gem, then run
      """.strip
      
      pre "erector app/views/foos/*.html.erb"

      p "or just"

      pre "erector app/views"

      p "and then delete the original files when you're satisfied."

      p "Here's a little command-line howto for erecting a scaffold Rails app:"

      pre <<DONE
rails foo
cd foo
script/generate scaffold post title:string body:text published:boolean

erector app/views/posts

mate app/views/posts
sleep 30 # this should be enough time for you to stop drooling

rm app/views/posts/*.erb
(echo ""; echo "require 'erector'") >> config/environment.rb
rake db:migrate
script/server
open http://localhost:3000/posts
DONE
      p do
        text "On the erector-to-html side, pass in the "
        code "--to-html"
        text "option and some file names and it will render the erector widgets to appropriately-named HTML files."
        text " We're actually using "
        code "erector"
        text " to build this Erector documentation web site that you're reading "
        b "right now."
        text " Check out the 'web' directory and the 'web' task in the Rakefile to see how it's done."
      end
    end,


    Section.new("Layout Inheritance") do
      p "Erector replaces the typical Rails layout mechanism with a more natural construct, the use of inheritance. Want a common
      layout? Just implement a layout superclass and inherit from it. Implement content in the superclass and implement template
      methods in its subclasses."
      
      p do
        text "For example:"
        pre <<-DONE
class Views::Layouts::Page < Erector::Widget
  def content
    html do
      head do
        title "MyApp - \#{page_title}"
        css "myapp.css"
      end
      body do
        div :class => 'sidebar' do
          render_sidebar
        end
        div :class => 'body' do
          render_body
        end
        div :class => 'footer' do
          render_footer
        end
      end
    end
  end

  def render_sidebar
    a "MyApp Home", :href => "/"
  end

  def render_body
    p "This page intentionally left blank."
  end

  def render_footer
    p "Copyright (c) 2112, Rush Enterprises Inc."
  end
end
        DONE

        pre <<-DONE
class Views::Faq::Index < Views::Layouts::Page
  def initialize
    super(:page_title => "FAQ")
  end

  def render_body
    p "Q: Why is the sky blue?"
    p "A: To get to the other side"
  end

  def render_sidebar
    super
    a "More FAQs", :href => "http://faqs.org"
  end
end
      DONE
        end
        p "Notice how this mechanism allows you to..."
        ul do
          li "Set instance variables (e.g. title)"
          li "Override sections completely (e.g. render_body)"
          li "Append to standard content (e.g. render_sidebar)"
          li "Use standard content unchanged (e.g. render_footer)"
        end
        p "all in a straightforward, easily understood paradigm (OO inheritance). (No more weird yielding to invisible, undocumented closures!)"
        p do
          text "To use this in Rails, declare "
          code "layout nil"
          text " in "
          code "app/controllers/application.rb"
          text " and then define your Page parent class as "
          code "class Views::Layouts::Page"
          text " in "
          code "app/views/layouts"
          text " as usual."
        end
      
      p "There's one trick you'll need to use this layout for non-erector view templates. Here's an example."

      p do
        code "application.rb"
        text " - The Erector layout superclass"
        pre <<DONE
class Views::Layouts::Application < Erector::Widget
  attr_accessor :content

  def content
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

    Section.new("Inline Widgets", "inline") do
      p do
        text "Instead of subclassing "
        code "Erector::Widget"
        text " and implementing a "
        code "content"
        text " method, you can pass a block to "
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
      
      p do
        text "One extra bonus feature of inline widgets is that they can call methods defined on the parent class, even though they're out of scope. How do they do this? Through method_missing magic. (But isn't method_missing magic against the design goals of Erector? Yes, some would say so, and we're probably going to discuss this feature on the mailing list before long.)"
      end
    end,

    Section.new("Needs") do
      p do
        text "Named parameters are fun, but one frustrating aspect of the 'options hash' technique is that "
        text "the code is less self-documenting and doesn't 'fail fast' if you pass in the wrong parameters, "
        text "or fail to pass in the right ones. Even simple typos can lead to very annoying debugging problems."
      end
      
      p do
        text "To help this, we've added an optional feature by which your widget can declare that it "
        text "needs a certain set of named parameters to be passed in. "
        text "For example:"
        pre <<-DONE
class Car < Erector::Widget
  needs :engine, :wheels => 4
  def content
    text "My \#{@wheels} wheels go round and round; my \#{@engine} goes vroom!"
  end
end
        DONE
        text "This widget will throw an exception if you fail to pass "
        code ":engine => 'V-8'"
        text " into its constructor. (Actually, it will work with any engine, but a V-8 is the baddest.)"
      end
      
      p do
        text "See the "
        a "rdoc for Widget#needs", :href => 'rdoc/classes/Erector/Widget.html#M000053'
        text " for more details. Note that as of version 0.7.0, using "
        code "needs"
        text " no longer automatically declares accessor methods."
      end
    end
    
    ])
  end
end

