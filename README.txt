= Erector

* http://erector.rubyforge.org
* mailto:alex@pivotallabs.com


== DESCRIPTION

Erector is a Builder-based view framework, inspired by Markaby but overcoming some of its flaws. In Erector all views are
objects, not template files, which allows the full power of OO (inheritance, modular decomposition, encapsulation) in views.

== FEATURES/PROBLEMS:

This is a *prerelease work in progress* and this gem is **NOT READY FOR USE** by anyone who's not on the Erector team yet. We'll be rolling out a
version 0.2.0 soon which should include howto documentation and such.

== SYNOPSIS

TODO (HOWTO, sample code, etc.)

== REQUIREMENTS

* treetop

== INSTALL

To install as a gem:

* sudo gem install erector

To install as a plugin:

* ???

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

== DOCUMENTATION

TODO

=== Layout Inheritance

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
