= Erector

* http://erector.rubyforge.org
* mailto:erector@googlegroups.com
* http://www.pivotaltracker.com/projects/482

== DESCRIPTION

Erector is a Builder-like view framework, inspired by Markaby but overcoming
some of its flaws. In Erector all views are objects, not template files,
which allows the full power of object-oriented programming (inheritance,
modular decomposition, encapsulation) in views. See the rdoc for the
Erector::Widget class to learn how to make your own widgets, and visit the
project site at http://erector.rubyforge.org for more documentation.

== SYNOPSIS

    require 'erector'

    class Hello < Erector::Widget
      def content
        html do
          head do
            title "Hello"
          end
          body do
            text "Hello, "
            b "#{target}!", :class => 'big'
          end
        end
      end
    end

    Hello.new(:target => 'world').to_s
    => "<html><head><title>Hello</title></head><body>Hello, <b class=\"big\">world!</b></body></html>"

== REQUIREMENTS

The gem depends on rake and treetop, although this is just for using the "erect" tool, 
so deployed applications won't need these. Currently it also requires rails, although
we plan to separate the rails-dependent code so you can use Erector cleanly in a non-Rails app.

== INSTALL

To install as a gem:

* sudo gem install erector

Then add "require 'erector'" to any files which need erector.

To install as a Rails plugin:

* Copy the erector source to vendor/plugins/erector in your Rails directory.

When installing this way, erector is automatically available to your Rails code
(no require directive is needed).

== LICENSE:

(The MIT License)

Copyright (c) 2007-2009 Pivotal Labs

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
