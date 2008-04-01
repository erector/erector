= Erector

* http://erector.rubyforge.org
* mailto:alex@pivotallabs.com


== DESCRIPTION

Erector is a Builder-like view framework, inspired by Markaby but overcoming some of its flaws. In Erector all views are
objects, not template files, which allows the full power of object-oriented programming (inheritance, modular decomposition, encapsulation) in views.

== FEATURES/PROBLEMS:

While Erector is in use on several projects, it is still at a relatively
early stage.  In particular, not all features are documented (although
the most important ones are).  

== SYNOPSIS

require 'erector' 
class YourView < Erector::Widget
  def render . . .
end

== REQUIREMENTS

The gem depends on hoe and rake, although this is just for building
erector (those who just use erector won't need these).

== INSTALL

To install as a gem:

* sudo gem install erector

Then add "require 'erector'" to any files which need erector.

To install as a plugin:

* Copy the erector source to vendor/plugins/erector in your rails
directory.  When installing this way, erector is automatically
available to your rails code (no require directive is needed).

== LICENSE:

(The MIT License)

Copyright (c) 2007-8 Pivotal Labs

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

== USER DOCUMENTATION

The basic way to construct some HTML/XML with erector is to 
subclass Erector::Widget and implement a render method:

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
  Hello.new.to_s  
  #=> <html><head><title>Hello</title></head><body>Hello, <b>world!</b></body></html>
  
Here are the basics:

  element('foo')           # <foo></foo>
  empty_element('foo')     # <foo />
  html                     # <html></html> (likewise for other common html tags)
  b "foo"                  # <b>foo</b>
  text 'foo'               # foo
  text '&<>'               # &amp;&lt;&gt; (what you generally want, especially
                           # if the text came from the user or a database)
  text raw('&<>')          # &<> (back door for raw html)
  rawtext('&<>')           # &<> (alias for text(raw()))
  html { text foo }        # <html>foo</html>
  html "foo"               # <html>foo</html>
  html foo                 # <html>bar</html> (if the method foo returns the string "bar")
  a(:href => 'foo.html')   # <a href="foo.html"></a>
  a(:href => 'q?a&b')      # <a href="q?a&amp;b"></a>  (quotes as for text)
  a(:href => raw('&amp;')) # <a href="&amp;"></a>
  text nbsp("Save Doc")    # Save&#160;Doc (turns spaces into non-breaking spaces)
  instruct                 # <?xml version="1.0" encoding="UTF-8"?>

TODO: document more obscure features like capture, Table, :class => ['one', 'two']

=== Using erector from rails

Your views are just ruby classes.  Your controller instantiates the
relevant view and calls render.  For example:

app/controllers/welcome_controller.rb:

  class WelcomeController < ApplicationController

    def index
      render :text => Views::Welcome::Show.new().to_s
    end

  end

app/views/welcome/show.rb:

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

=== Layout Inheritance

This section describes how to mix erector with other rendering systems.
Erector replaces the typical Rails layout mechanism with a more natural construct, the use of inheritance. Want a common
layout? Just implement a layout superclass and inherit from it. Implement render in the superclass and implement template
methods in its subclasses. There's one trick you'll need to use this layout for non-erector templates. Here's an example.

`application.rb` - The Erector layout superclass

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

`application.mab` - The markaby template (adjust for other appropriately templating technologies)

    widget = Views::Layouts::Application.new(self)
    widget.content = content_for_layout
    self << widget.to_s

Here the abstract layout widget is used in a concrete fashion by the template-based layout. Normally, the `content` method
would be implemented by subclassing widgets, but the layout template sets it directly and then calls to_s on the layout widget.
This allows the same layout to be shared in a backward compatible way.

=== Other ways to call erector

Instead of subclassing Erector::Widget and implementing a render
method, you can pass a block to Erector::Widget.new.  For example:

  html = Erector::Widget.new do
    p "Hello, world!"
  end
  html.to_s          #=> <p>Hello, world!</p>

== DEVELOPER NOTES

* Check out project from rubyforge: 

  svn co svn+ssh://developername@rubyforge.org/var/svn/erector/trunk erector

* Install gems:

  sudo gem install rake rails rspec rubyforge hpricot

* Run specs:

  rake

* Check out the available rake tasks:

  rake -T


=== VERSIONING POLICY

* Versions are of the form major.minor.tiny
* Tiny revisions fix bugs or documentation
* Tiny revisions are roughly equal to the svn revision number when they were made
* Minor revisions add API calls, or change behavior
* Minor revisions may also remove API calls, but these must be clearly announced in History.txt, with instructions on how to migrate 
* Major revisions are about marketing more than technical needs. We will stay in major version 0 until we're happy taking the "alpha" label off it. And if we ever do a major overhaul of the API, especially one that breaks backwards compatibility, we will probably want to increment the major version.
* We will not be shy about incrementing version numbers -- if we end up going to version 0.943.67 then so be it.
* Developers should attempt to add lines in History.txt to reflect their checkins. These should reflect feature-level changes, not just one line per checkin. The top section of History.txt is used as the Release Notes by the "rake publish" task and will appear on the RubyForge file page.
* Someone making a release must fill in the version number in History.txt as well as in Rakefile. Note that "rake publish" requires a "VERSION=1.2.3" parameter to confirm you're releasing the version you intend.
* As soon as a release is made and published, the publisher should go into History.txt and make a new section. Since we won't yet know what the next version will be called, the new section will be noted by a single "==" at the top of the file. 


