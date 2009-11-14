# Erector Page base class.
#
# Allows for accumulation of script and style tags (see example below) with either
# external or inline content. External references are 'uniq'd, so it's a good idea to declare
# a js script in all widgets that use it, so you don't accidentally lose the script if you remove 
# the one widget that happened to declare it.
#
# The script and style declarations are accumulated at class load time, as 'externals'.
# This technique allows all widgets to add their own requirements to the page header
# without extra logic for declaring which pages include which nested widgets.
# Unfortunately, this means that every page in the application will share the same headers,
# which may lead to conflicts.
#
# If you want something to show up in the headers for just one page type (subclass),
# then override #head_content, call super, and then emit it yourself.
#
# Body content can be supplied in several ways:
#
#   * In a Page subclass, by overriding the #body_content method:
#
#      class MyPage < Erector::Widgets::Page
#        def body_content
#          text "body content"
#        end
#      end
#
#   * Or by overriding #content and passing a block to super:
#
#      class MyPage < Erector::Widgets::Page
#        def content
#          super do
#            text "body content"
#          end
#        end
#      end
#
#   * Or by passing a block to Page.new:
#
#      Erector::Widgets::Page.new do
#        text "body content"
#      end
#
# This last trick (passing a block to Page.new) works because Page is an InlineWidget 
# so its block is evaluated in the context of the newly instantiated widget object, 
# and not in the context of its caller. But this means you can't access instance variables
# of the caller, e.g.
# 
#      @name = "fred"
#      Erector::Widgets::Page.new do
#        text "my name is #{@name}"
#      end
#
# will emit "my name is " because @name is nil inside the new Page. However, you *can* 
# call methods in the parent class, thanks to some method_missing magic. Confused? You 
# should be. See Erector::Inline#content for more documentation.
#
# Author::   Alex Chaffee, alex@stinky.com 
#
# = Example Usage: 
#
#   class MyPage < Page
#     external :js, "lib/jquery.js"
#     external :script, "$(document).ready(function(){...});"
#     external :css, "stuff.css"
#     external :style, "li.foo { color: red; }"
#     
#     def page_title
#       "my app"
#     end
#     
#     def body_content
#       h1 "My App"
#       p "welcome to my app"
#       widget WidgetWithExternalStyle
#     end
#   end
# 
#   class WidgetWithExternalStyle < Erector::Widget
#     external :style, "div.custom { border: 2px solid green; }"
#     
#     def content
#       div :class => "custom" do
#         text "green is good"
#       end
#     end
#   end
#
# = Thoughts:
#  * It may be desirable to unify #js and #script, and #css and #style, and have the routine be
#    smart enough to analyze its parameter to decide whether to make it a file or a script.
#
class Erector::Widgets::Page < Erector::InlineWidget

  # Emit the Transitional doctype.
  # TODO: allow selection from among different standard doctypes
  def doctype
    '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
       "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">'
  end

  def content
    rawtext doctype
    html(html_attributes) do
      head do
        head_content
      end
      body(body_attributes) do
        if block_given?
          yield
        elsif @block
          super
        else
          body_content
        end
      end
    end
  end

  # override me to provide a page title (default = name of the Page subclass)
  def page_title
    self.class.name
  end
  
  # override me to change the attributes of the HTML element
  def html_attributes
    {:xmlns => 'http://www.w3.org/1999/xhtml', 'xml:lang' => 'en', :lang => 'en'}
  end
  
  # override me to add attributes (e.g. a css class) to the body
  def body_attributes
    {}
  end

  # override me (or instantiate Page with a block)
  def body_content
  end

  # emit the contents of the head element. Override and call super if you want to put more stuff in there.
  def head_content
    meta 'http-equiv' => 'content-type', :content => 'text/html;charset=UTF-8'
    title page_title

    included_stylesheets
    inline_styles

    included_scripts
    inline_scripts
  end
  
  def included_scripts
    self.class.externals(:js).each do |external|
      script({:type => "text/javascript", :src => external.text}.merge(external.options))
    end
  end
  
  def included_stylesheets
    self.class.externals(:css).each do |external|
      link({:rel => "stylesheet", :href => external.text, :type => "text/css", :media => "all"}.merge(external.options))
    end
  end

  def inline_styles
    self.class.externals(:style).each do |external|
      style({:type => "text/css", 'xml:space' => 'preserve'}.merge(external.options)) do
        rawtext external.text
      end
    end
  end
  
  def inline_scripts
    self.class.externals(:script).each do |external|
      javascript external.options do
        rawtext external.text
      end
    end
    self.class.externals(:jquery).each do |external|
      javascript external.options do
        jquery_ready external.text
      end
    end
  end

end
