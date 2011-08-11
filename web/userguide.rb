dir = File.dirname(__FILE__)
require "#{dir}/page"
require "#{dir}/navbar"
require "#{dir}/article"
require "#{dir}/section"

class Userguide < Page
  def initialize
    super(:page_title => "User Guide")
  end

  def promo
    "images/1959erector.jpeg"
  end
  
  def body_content
    p do
      text "Make sure to check out the ",
        a("RDoc Documentation", :href => "rdoc"),
        " for more details on the API."
    end

    widget article
  end

  def article
    Article.new(:name => "Erector User Guide").tap { |a|

      a.add(:name => "The Basics") do
        p do
          text "The basic way to construct some HTML/XML with erector is to subclass ",
            code("Erector::Widget"),
            " and implement a ",
            code("content"),
            " method:"
        end
        
      table do
        tr do
          td :valign => "top" do
            source :ruby, <<-RUBY
class Hello < Erector::Widget
  def content
    html {
      head {
        title "Hello"
      }
      body {
        text "Hello, "
        b "world!"
      }
    }
  end
end
            RUBY
          end
          td do
            span.separator do
              text character(:rightwards_arrow)
            end
          end
          td :valign => "top" do
            source :html, <<-HTML
<html>
  <head>
    <title>Hello</title>
  </head>
  <body>
  Hello, <b>world!</b>
  </body>
</html>
            HTML
          end
        end
      end

      p do
        text "Once you have a widget class, you can instantiate it and then call its "
        code "to_html"
        text " method."
        text " If you want to pass in 'locals' (aka 'assigns'), then do so in the constructor's default hash. This will make instance variables of the same name, with Ruby's '@' sign."
      end
      source :ruby, <<-PRE
class Email < Erector::Widget
  def content
    a @address, :href => "mailto:#{@address}"
  end
end

>> Email.new(:address => "foo@example.com").to_html
=> "<a href=\"mailto:foo@example.com\">foo@example.com</a>"
      PRE
      p do
        text "(If you want control over which locals are valid to be passed in to a widget, use the "
        a "needs", :href => "#needs"
        text " macro.)"
      end
    end

    a.add(:name => "Mixin") do
      p "If all this widget stuff is too complicated, just do "
      pre "include Erector::Mixin"
      p do
        text "and then call "
        code "erector { }"
        text " from anywhere in your code. It will make an "
        a "inline widget", :href => "#inline"
        text " for you, pass in the block, and call "
        code "to_html"
        text " on it. And if you pass any options to "
        code "erector"
        text ", like "
        code ":prettyprint => true"
        text ", it'll pass them along to "
        code "to_html"
        text "!"
      end
      h3 "Examples:"
      source :ruby, <<-PRE
erector { a "lols", :href => "http://icanhascheezburger.com/" }
=> "<a href=\\"http://icanhascheezburger.com/\\">lols</a>"

erector(:prettyprint => true) do
  ol {
    li "bacon"
    li "lettuce"
    li "tomato"
  }
end
=> "<ol>\\n  <li>bacon</li>\\n  <li>lettuce</li>\\n  <li>tomato</li>\\n</ol>\\n"
      PRE

    end

    a.add(:name => "Pretty-printing") do
      p "Erector has the ability to insert newlines and indentation to make the generated HTML more readable.  Newlines are inserted before and after certain tags."
      p "To enable pretty-printing (insertion of newlines and indentation) of Erector's output, do one of the following:"
      ul do
        li do
          text "call "
          code "to_pretty"
          text " instead of "
          code "to_html"
          text " on your Erector::Widget"
        end
        li do
          text "pass "
          code ":prettyprint => true"
          text " to "
          code "to_html"
        end
        li do
          text "call "
          code "enable_prettyprint(true)"
          text " on your Erector::Widget.  Then subsequent calls to "
          code "to_html"
          text " will prettyprint"
        end
        li do
          text "call "
          code "Erector::Widget.prettyprint_default = true"
          text " (for example, in environments/development.rb in a rails application, or anywhere which is convenient)"
        end
      end
    end

    a.add(:name => "Using Erector from Ruby on Rails", :href => "rails") do
      p do
        text "Your views are just ruby classes.  Your controller can either call Rails' "
        code "render :template"
        text " method as usual, or directly instantiate the view class and call its content method."
      end

      p "For example:"

      code "app/controllers/welcome_controller.rb:"
      source :ruby, <<-DONE
class WelcomeController < ApplicationController
  def index
    render :template => 'welcome/show'
  end
end
DONE

      code "app/views/welcome/show.rb:"
      source :ruby, <<-DONE
class Views::Welcome::Show < Erector::Widget
  def content
    html {
      head {
        title "Welcome page"
      }
      body {
        p "Hello, world"
      }
    }
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

    end

    a.add(:name => "Erector tool: Command-line conversion to and from HTML", :href => "tool") do

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

      source :sh, <<-DONE
# create a toy Rails app
rails foo
cd foo
script/generate scaffold post title:string body:text published:boolean

# convert all the "posts" views
erector app/views/posts

# remove the old ERB views
rm app/views/posts/*.erb

# a little configuration step
(echo ""; echo "require 'erector'") >> config/environment.rb

# launch the app and make sure it works
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
    end


    a.add(:name => "Page Layout Inheritance") do
      p "Erector replaces the typical Rails layout mechanism with a more natural construct, the use of inheritance. Want a common
      layout? Implement a layout superclass and have your page class inherit from it and override methods as needed."

      p do
        text "For example:"
        source :ruby, <<-DONE
class Views::Layouts::Page < Erector::Widget
  def content
    html {
      head {
        title "MyApp - \#{@page_title}"
        css "myapp.css"
      }
      body {
        div.navbar {
          navbar
        }
        div.main {
          main
        }
        div.footer {
          footer
        }
      }
    }
  end

  def navbar
    a "MyApp Home", :href => "/"
  end

  def main
    p "This page intentionally left blank."
  end

  def footer
    p "Copyright (c) 2112, Rush Enterprises Inc."
  end
end
        DONE

        source :ruby, <<-DONE
class Views::Faq::Index < Views::Layouts::Page
  def initialize
    super(:page_title => "FAQ")
  end

  def main
    p "Q: Why is the sky blue?"
    p "A: To get to the other side"
  end

  def navbar
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
          li "Append to standard content (e.g. render_navbar)"
          li "Use standard content unchanged (e.g. render_footer)"
        end
        p "all in a straightforward, easily understood paradigm (OO inheritance). (No more weird yielding to invisible, undocumented closures!)"
        p {
         text "Check out "
         a "Erector::Widgets::Page", :href => "/rdoc/Erector/Widgets/Page.html"
         text " for a widget that does a lot of this for you, including rendering "
         a "externals", :href => "#externals"
         text " in the HEAD element."
        }
      end
      
      a.add(:name => "Erector Layouts in Rails") do

      p do
        text "To use layout inheritance in Rails, declare "
        code "layout nil"
        text " in "
        code "app/controllers/application.rb"
        text " and then define your Page parent class as "
        code "class Views::Layouts::Page"
        text " in "
        code "app/views/layouts"
        text " as usual."
      end
      p do
        text "To use an Erector widget as a regular Rails layout, you'll have to set things up a bit differently."
        br
        code "app/views/layouts/application.rb:"
        source :ruby, <<-RUBY
class Views::Layouts::Application < Erector::Widget
  def content
    html {
      head {
        title "MyApp - \#{page_title}"
        css "myapp.css"
      }
      body {
        div.navbar {
          navbar
        }
        div.main {
          content_for :layout
        }
        div.footer {
          footer
        }
      }
    }
  end

  def navbar
    ul {
      li { a "MyApp Home", :href => "/" }
      content_for :navbar if content_for? :navbar
    }
  end

  def footer
    p "Copyright (c) 2112, Rush Enterprises Inc."
    content_for :footer if content_for? :footer    
  end

end
        RUBY
        
        br
        code "app/views/faq/index.rb:"
        
        source :ruby, <<-RUBY
class Views::Faq::Index < Erector::Widget
  def content
    content_for :navbar do
      li { a "More FAQs", :href => "http://faqs.org" }
    end

    p "Q: Why is the sky blue?"
    p "A: To get to the other side"
  end
end
        RUBY

        p "[TODO: more explanation]"
        
      end
    end

    a.add(:name => "Inline Widgets") do
      p do
        text "Instead of subclassing "
        code "Erector::Widget"
        text " and implementing a "
        code "content"
        text " method, you can pass a block to "
        code "Erector.inline"
        text " and get back a widget instance you can call "
        code "to_html"
        text " on.  For example:"
        source :ruby, <<-DONE
hello = Erector.inline do
  p "Hello, world!"
end
hello.to_html          #=> <p>Hello, world!</p>
        DONE
        text "This lets you define mini-widgets on the fly."
      end

      p do
        text "If you're in Rails, your inline block has access to Rails helpers if you pass a helpers object to "
        code "to_html"
        text ":"
        source :ruby, <<-DONE
image = Erector.inline do
  image_tag("/foo")
end
image.to_html(:helpers => controller)          #=> <img alt="Foo" src="/foo" />
      DONE
    end

      p do
        text "Note that inline widgets are usually redundant if you're already inside an Erector content method. You can just use a normal "
        code "do"
        text " block and the Erector methods will work as usual when called back from "
        code "yield"
        text ". Inline widgets get evaluated with "
        code "instance_eval"
        text " which may or may not be what you want. See the section on "
        a "blocks", :href=>"#blocks"
        text " in this user guide for more detail."
      end

      p do
        text "One extra bonus feature of inline widgets is that they can call methods defined on the parent class, even though they're out of scope. How do they do this? Through method_missing magic. (But isn't method_missing magic against the design goals of Erector? Yes, some would say so, and that's why we're reserving it for a special subclass and method. For Erector::Widget and subclasses, if you pass in a block, it's a plain old block with normal semantics.) But they can't directly access instance variables on the parent, so watch it."
      end
    end

    a.add(:name => "Needs") do
      p do
        text "Named parameters in Ruby are fun, but one frustrating aspect of the 'options hash' technique is that "
        text "the code is less self-documenting and doesn't 'fail fast' if you pass in the wrong parameters, "
        text "or fail to pass in the right ones. Even simple typos can lead to very annoying debugging problems."
      end

      p do
        text "To help this, we've added an optional feature by which your widget can declare that it "
        text "needs a certain set of named parameters to be passed in. "
        text "For example:"
        source :ruby, <<-DONE
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

    a.add(:name => "Externals") do
      p do
        text "Erector's got some nice tags, like "
        code "script"
        text " and "
        code "style"
        text ", that you can emit in the content method of your widget. But what if your widget needs something, say a JavaScript library, that should be included not in the main page, but inside the "
        code "head"
        text " section?"
      end
      p do
        a "Externals", :href => "rdoc/classes/Erector/Externals.html"
        text " are a way for your widget to announce to the world that it has an external dependency. It's then up to "
        a "another widget", :href => "rdoc/classes/Erector/Widgets/Page.html"
        text " to emit that dependency while it's rendering the "
        code "head"
        text "."
      end
      p do
        text "Here's an example:"
        source :ruby, <<-DONE
class HotSauce < Erector::Widget
  depends_on :css, "/css/tapatio.css"
  depends_on :css, "/css/salsa_picante.css", :media => "print"
  depends_on :js, "/lib/jquery.js"
  depends_on :js, "/lib/picante.js"

  def content
    p.hot_sauce {
      text "esta salsa es muy picante!"
    }
  end
end
        DONE
        text "Then when "
        code "Page"
        text " emits the "
        code "head"
        text " it'll look like this:"
        source :ruby, <<-DONE
<head>
  <meta content="text/html;charset=UTF-8" http-equiv="content-type" />
  <title>HotPage</title>
  <link href="/css/tapatio.css" media="all" rel="stylesheet" type="text/css" />
  <link href="/css/salsa_picante.css" media="print" rel="stylesheet" type="text/css" />
  <script src="/lib/jquery.js" type="text/javascript"></script>
  <script src="/lib/picante.js" type="text/javascript"></script>
</head>
        DONE
      end
      
      p do
        text "It also collapses redundant externals, so if lots of your widgets declare the same thing (say, 'jquery.js'), it'll only get included once."
      end

      p do
        a "Page", :href => "rdoc/classes/Erector/Widgets/Page.html"
        text " looks for the following externals:"
        table do
          tr do
            th ":js"
            td "included JavaScript file"
          end
          tr do
            th ":css"
            td "included CSS stylesheet"
          end
          tr do
            th ":script"
            td "inline JavaScript"
          end
          tr do
            th ":style"
            td "inline CSS style"
          end
        end
        text "It might be a little difficult to remember the difference between :js and :script, and between :css and :style, so I'm thinking of maybe unifying them and looking at the content to determine whether it's inline or not. (Something simple like, if it includes a space, then it's inline.) Good idea? Let us know on "
        a "the erector mailing list", :href => "http://googlegroups.com/group/erector"
        text "!"
      end

      p do
        text "Instead of a string, you can also specify a File object; the file's contents get read and used as text. This allows you to inline files instead of referring to them, for potential performance benefits."
        text " Example:"
        source :ruby, <<-DONE
    depends_on :style, File.new("\#{File.dirname(__FILE__)}/../public/sample.css")
        DONE
      end
    end

    a.add(:name => "Blocks") do
      p "Erector is all about blocks (otherwise known as closures). Unfortunately, there are some confusing aspects to working with blocks; this section aims to clarify the issues so if you find yourself stuck on an 'undefined method' or a nil instance variable, at least you'll have some context to help debug it."
      p "There are basically three cases where you can pass a block to Erector:"
      h3 "1. To an element method"
      p "This is the normal case that provides the slick HTML DSL. In the following code:"
      source :ruby, <<-DONE
class Person < Erector::Widget
  def content
    div {
      h3 @name
      p {
        b "Birthday: "
        span @birthday
      }
    }
  end
end
      DONE
      p do
        text "the blocks passed in to "
        code "div"
        text " and "
        code "p"
        text " are evaluated using normal "
        code "yield"
        text " semantics, and the "
        code "@name"
        text " and "
        code "@birthday"
        text " instance variables are evaluated in the context of the Person instance being rendered."
      end
      p "So far, so good."

      h3 "2. To the constructor of an Erector::Widget"
      p do
        text "In this case you can build a widget \"on the fly\" and have it render whatever it wants, then call your block. This is useful for widgets like "
        code "Form"
        text " which want to wrap your HTML in some of their own tags."
      end
      source :ruby, <<-DONE
class PersonActions < Erector::Widget
  needs :user
  def content
    div {
      widget(Form.new(:action => "/person/\#{@user.id}", :method => "delete") {
        input :type => "submit", :value => "Remove \#{@user.name}"
      })
      widget(Form.new(:action => "/person/\#{@user.id}/email", :method => "post") {
        b "Send message: "
        input :type => "text", :name => "message"
        input :type => "submit", :value => "Email \#{@user.name}"
      })
    }
  end
end
      DONE
      p do
        text "In this case, you will get two "
        code "form"
        text " elements, each of which has some boilerplate HTML for emitting the form element, emitting the hidden "
        code "_method"
        text " input tag in the case of the delete method, then calling back into your widget to emit the contents of the form. In this case, as above, the "
        code "@user"
        text " instance variable will be sought inside the "
        b "calling"
        text " widget"
        code "(PersonActions)"
        text ", not the "
        b "called "
        text " widget"
        code "(Form)"
        text "."
      end

      p do
        text "A quirk of this technique is that methods inside the block will be called on the calling widget, not the called widget. This doesn't cause any problems for element methods ("
        code "b"
        text " and "
        code "input"
        text " above"
        text "), but may be confusing if you want the block to be able to call methods on the target widget. In that case the caller can declare the block to take a parameter; this parameter will point to the nested widget instance."
        source :ruby, <<-DONE
widget(Form.new(:action => "/person/\#{@user.id}", :method => "delete") do |f|
  span "This form's method is \#{f.method}"
  input :type => "submit", :value => "Remove \#{@user.name}"
end)
        DONE
      end

      p do
        text "(As a variant of this case, note that the"
        code "widget"
        text " method can accept a widget class, hash and block, instead of an instance; in this case it will set the widget's block and this code:"
        source :ruby, <<-DONE
widget Form, :action => "/person/\#{@user.id}", :method => "delete" do
  input :type => "submit", :value => "Remove \#{@user.name}"
end
        DONE
        text " will work the same as the version above.)"
      end

      h3 "3. To the constructor of an Erector::InlineWidget"
      p do
        text "This is where things get hairy. Sometimes we want to construct a widget on the fly, but we're not inside a widget already. So any block we pass in will not have access to Erector methods. In this case we have a special subclass called "
        code "Erector::InlineWidget"
        text " which uses two magic tricks: "
        code "instance_eval"
        text " and "
        code "method_missing"
        text " to accomplish the following:"
        ul do
          li do
            text "inside the block, "
            code "self"
            text " points to the widget, not the caller."
          end
          li do
            text "methods will be looked for first on the inline widget, and then on the caller."
          end
          li do
            text "instance variables will be looked for on the inline widget "
            b "only"
            text ". This can be the source of many a nil! As a general rule, you should probably stay away from instance variables when using inline widgets. However..."
          end
          li do
            b "Bound"
            text " local variables will still be in scope. This means you can \"smuggle in\" instance variables via local variables. For example:"
            source :ruby, <<-DONE
local_name = @name
Page.new do
  div local_name
end.to_html
            DONE
          end
        end
        p do
          text "When using the "
          a "mixin", :href => "#mixin"
          text ", you get an inline widget, so the above list of tricks applies."
        end
        hr
        p do
          text "One note for developers: when creating a widget like "
        code "Form"
        text " that needs to call back to its block, use the method "
        code "call_block"
        text ", which calls the block and passes in self as appropriate for both inline and normal widgets."
      end
    end
  end
  }
  end
end
