= Erector

* http://erector.rubyforge.org
* mailto:alex@pivotallabs.com

== DESCRIPTION

Erector is a Builder-like view framework, inspired by Markaby but overcoming
some of its flaws. In Erector all views are objects, not template files,
which allows the full power of object-oriented programming (inheritance,
modular decomposition, encapsulation) in views.

== SYNOPSIS

    require 'erector'

    class Hello < Erector::Widget
      def render
        div do
          text "Hello!"
        end
      end
    end

== REQUIREMENTS

The gem depends on hoe and rake, although this is just for building
erector (those who just use erector won't need these).

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
