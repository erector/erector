dir = File.dirname(__FILE__)
require "#{dir}/page"
require "#{dir}/navbar"
require "#{dir}/article"
require "#{dir}/section"

class Rails < Page
  def initialize
    super(:page_title => "Erector On Rails")
  end

  def promo
    "images/erectorhudson.jpeg"
  end
  
  def body_content
    p do
      text "This page describes integrating Erector into ",
        a("Ruby on Rails", :href => "http://rubyonrails.org"),
        " apps. Read the ",
        a("User Guide", :href => "userguide.html"),
        " for details on Erector itself."
    end

    widget article
  end

  def article
    Article.new(:name => "Erector On Rails").tap { |a|
      a.add(:name => "Install") do
        p {          
          text "To install as a gem, add ", code("gem 'erector'"), " to your ", code("Gemfile"), 
            ", then add ", code("require 'erector'"), " to ", code("environment.rb"), "."
        }
        p  {
          text "To install as a Rails plugin, copy the erector source to ",
            code("vendor/plugins/erector"), " in your project directory. ",
            "When installing this way, erector is automatically available to your Rails code (no require directive is needed)."
        }
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

  }
  end
end
