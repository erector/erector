# Erector 0.6.0 Announcement

This release is the first major API change to Erector. It will definitely break
existing code. Sorry about that, but we promise it'll be cleaner afterwards.

## Quick Update Guide

* Rename 'def render' to 'def content' in all your widgets

* Change MyWidget.new(helpers, assigns, output) to just
  MyWidget.new(assigns)

* To render a widget from inside another widget, use

        widget MyWidget, :foo=>2
        
  or
  
        widget MyWidget.new(:foo => 2)

* If you want your variables to have attr\_readers, use 'needs'

* If you want your widgets to be more self-documenting, use 'needs'

## Major API changes

* "new" and "to\_s" have been changed to clarify the lifecycle of a widget,
  so "new" accepts permanent state ("assigns" variables) and "to\_s" accepts
  temporary, rendering state (output stream, helpers, and prettyprinting).
  This lets you do things like make collections of widgets in once place in
  your code and render them in another place.

* Renamed "render" to "content", which removes confusion/ambiguity with
  Rails' "render" method and concept, and also allows "render :partial" to
  be made to work (though we're not sure if that totally works yet).

* To render a widget from outside code, the pattern is:

        w = DateWidget.new(:when => Time.now, :title => "Nap Time")
        puts w.to_s(:helpers => some_rails_view)

* To render a widget from inside another widget:

        def content
          # first way... pass class and assigns
          widget DateWidget, :when => Time.now, :title => "Nap Time"
          # second way... pass instance
          widget DateWidget.new(:when => Time.now, :title => "Nap Time")
        end

  Using "widget" will improve performance over calling "raw foo.to\_s" or
  whatever since it reuses the same output stream.

* To declare variables -- and raise an exception when one is not provided:

        class JohnLennon < Erector::Widget
          needs :love
        end

* Formerly, every 'assigns' variable had an attr\_reader defined for it. Now,
  only variables declared with 'needs' get attr\_readers.

## Other changes:

* Removed Widget#to\_s caching, which fixed indentation issues.

* BUGFIX: Indentation level is now correctly propagated to nested widgets.

* Erector's Rails support strategy has changed. The released version of
  Erector only supports the latest stable Rails version (currently 2.3.2).
  If you need support for earlier versions of Rails, there are separate Git
  branches for each one, but we will not be in the habit of keeping these up
  to date with the latest features and patches. If someone wants to do a
  merge to a prior Rails branch, Brian will be happy to help :-)

