# Erector

* http://erector.github.io/erector
* mailto:erector@googlegroups.com
* http://github.com/erector/erector
* http://www.pivotaltracker.com/projects/482

## DESCRIPTION

Erector is a view framework. That is, it helps you generate HTML mixing in
dynamic content (like erb, slim or haml). Unlike erb, slim, or haml, views
are objects, not template files,
which allows the full power of object-oriented programming (inheritance,
modular decomposition, encapsulation) in views. See the rdoc for the
Erector::Widget class to learn how to make your own widgets, and visit the
project site at http://erector.github.io/erector for more documentation.

No, seriously, we've got hella docs at http://erector.github.io/erector -- go
check it out.

## SYNOPSIS
```ruby
    require 'erector'

    class Hello < Erector::Widget
      def content
        html do
          head do
            title "Hello"
          end
          body do
            text "Hello, "
            b @target, :class => 'big'
            text "!"
          end
        end
      end
    end

    Hello.new(:target => 'world').to_html
    => "<html><head><title>Hello</title></head><body>Hello, <b class=\"big\">world</b>!</body></html>"

    include Erector::Mixin
    erector { div "love", :class => "big" }
    => "<div class=\"big\">love</div>"
```
## REQUIREMENTS

The gem depends on rake and treetop, although this is just for using the command-line tool,
so deployed applications won't need these. The Rails-dependent code is now separated so
you can use Erector cleanly in a non-Rails app.

## INSTALL

To install as a gem:

* sudo gem install erector

Then add "require 'erector'" to any files which need erector.

To install as a Rails plugin:

* Copy the erector source to vendor/plugins/erector in your Rails directory.

When installing this way, erector is automatically available to your Rails code
(no require directive is needed).

## TESTS

Three spec rake tasks are provided: spec:core (core functionality),
spec:erect (the erector command line tool), and spec:rails (rails integration).

`rake spec` will run the complete set of specs.

## CONTRIBUTING

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

See web site docs for more details.

## CREDITS

Core Team:
* Alex Chaffee
* Jim Kingdon

Special Thanks To:
* Abby (Chaffee's muse & Best friend)
* Brian Takita
* Jeff Dean
* John Firebaugh
* Nathan Sobo
* Nick Kallen
* Alon Salant
* Andy Peterson

## VERSION HISTORY

see History.txt

## LICENSE: MIT

see LICENSE.txt

## SEE ALSO

The [fortitude](https://github.com/ageweke/fortitude) gem is similar. Pick that one
if you want better integration with tilt (the template rendering mechanism used
in Sinatra and many other ruby web frameworks).
