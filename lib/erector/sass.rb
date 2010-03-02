
if Object.const_defined?(:Sass)
  module Erector
    # Adds sass support to Erector widgets. 
    # Note that sass is provided inside the gem named "haml", 
    # not the gem named "sass".
    # To get sass support into your Erector project, install the 
    # haml gem -- see http://sass-lang.com/download.html -- and
    # then do something like this:
    #     require 'rubygems'
    #     require 'sass'
    #
    # Current support is barebones. Please offer suggestions (or better
    # yet, patches) for whether and how to support, e.g., caching, 
    # loading from files, precompilation, etc.
    module Sass
      def sass(sass_text)
        style ::Sass::Engine.new(sass_text, :cache => false).render
      end
    end
  end
end
