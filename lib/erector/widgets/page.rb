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
# If you want something to show up in the headers
# for just one page, override #head_content, call super, and then emit it yourself.
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
class Page < Erector::Widget

  # Emit the Transitional doctype.
  # TODO: allow selection from among different standard doctypes
  def doctype
    '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
       "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">'
  end

  # override me
  def page_title
    self.class.name
  end

  def content
    rawtext doctype
    # todo: allow customization of xmlns and xml:lang
    html :xmlns => 'http://www.w3.org/1999/xhtml', 'xml:lang' => 'en', :lang => 'en' do
      head do
        head_content
      end
      body do
        body_content
      end
    end
  end

  # override me (or instantiate Page with a block)
  def body_content
    instance_eval(&@block) if @block
  end

  # emit the contents of the head element. Override and call super if you want to put more stuff in there.
  def head_content
    meta 'http-equiv' => 'content-type', :content => 'text/html;charset=UTF-8'
    title page_title
    included_scripts
    included_stylesheets
    inline_styles
    inline_scripts
  end
  
  def included_scripts
    externals(:js).each do |file|
      script :type=>"text/javascript", :src => file
    end
  end
  
  def included_stylesheets
    externals(:css).each do |file|
      # todo: allow different media
      link :rel => "stylesheet", :href => file, :type => "text/css", :media => "all"
    end
  end

  def inline_styles
    style :type=>"text/css", 'xml:space' => 'preserve' do
      rawtext "\n"
      externals(:style).each do |txt|
        rawtext "\n"
        rawtext txt
      end
    end
  end
  
  def inline_scripts
    javascript do
      externals(:script).each do |txt|
        rawtext "\n"
        rawtext txt
      end
      externals(:jquery).each do |txt|
        jquery_ready txt
      end
    end
  end

  # some *very* basic styles, hopefully not too controversial
  external :style, <<-STYLE
    img {border: none}
    .right {float: right;}
    .left {float: left;}
    .clear {background: none;border: 0;clear: both;display: block;float: none;font-size: 0;margin: 0;padding: 0;position: static;overflow: hidden;visibility: hidden;width: 0;height: 0;}
  STYLE
  
end

class Erector::Widget
  # declares a jQuery script that is to be run on document ready
  def jquery(txt)
    javascript do
      jquery_ready txt
    end
  end

  protected
  def jquery_ready(txt)
    rawtext "\n"
    rawtext "$(document).ready(function(){\n"
    rawtext txt
    rawtext "\n});"
  end
end
