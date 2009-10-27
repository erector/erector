# Erector Page base class.
#
# Allows for accumulation of script and style tags (see example below) with either
# external or inline content. External references are 'uniq'd, so it's a good idea to declare
# a js script in all widgets that use it, so you don't accidentally lose the script if you remove 
# the one widget that happened to declare it.
#
# At minimum, child classes must override #body_content. You can also get a "quick and dirty"
# page by passing a block to Page.new but that doesn't really buy you much.
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
class Erector::Widgets::Page < Erector::Widget

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
        body_content
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
    instance_eval(&@block) if @block
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
        rawtext txt
      end
    end
    self.class.externals(:jquery).each do |external|
      javascript external.options do
        jquery_ready txt
      end
    end
  end

end
