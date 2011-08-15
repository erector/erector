require "erector/element"
require "erector/attributes"
require "erector/promise"
require "erector/text"
require "erector/tag"
require "erector/html_widget"
require "erector/needs"

module Erector

  # A Widget is the center of the Erector universe.
  #
  # To create a widget, extend Erector::Widget and implement the +content+
  # method. Inside this method you may call any of the tag methods like +span+
  # or +p+ to emit HTML/XML tags.
  #
  # You can also define a widget on the fly by passing a block to +new+. This
  # block will get executed when the widget's +content+ method is called. See
  # the userguide for important details about the scope of this block when run --
  # http://erector.rubyforge.org/userguide.html#blocks
  #
  # To render a widget from the outside, instantiate it and call its +to_html+
  # method.
  #
  # A widget's +new+ method optionally accepts an options hash. Entries in
  # this hash are converted to instance variables.
  #
  # You can add runtime input checking via the +needs+ macro. See #needs.
  # This mechanism is meant to ameliorate development-time confusion about
  # exactly what parameters are supported by a given widget, avoiding
  # confusing runtime NilClass errors.
  #
  # To call one widget from another, inside the parent widget's +content+
  # method, instantiate the child widget and call the +widget+ method. This
  # assures that the same output stream is used, which gives better
  # performance than using +capture+ or +to_html+. It also preserves the
  # indentation and helpers of the enclosing class.
  #
  # In this documentation we've tried to keep the distinction clear between
  # methods that *emit* text and those that *return* text. "Emit" means that
  # it writes to the output stream; "return" means that it returns a string
  # like a normal method and leaves it up to the caller to emit that string if
  # it wants.
  #
  # This class extends AbstractWidget and includes several modules,
  # so be sure to check all of those places for API documentation for the
  # various methods of Widget:
  #
  # * AbstractWidget
  # * Element
  # * Attributes
  # * Text
  # * Needs
  # * Caching
  # * Externals
  # * AfterInitialize
  #
  # * HTML
  # * Convenience
  # * JQuery
  # * Sass
  #
  # Also read the API Cheatsheet in the user guide
  # at http://erector.rubyforge.org/userguide#apicheatsheet
  class Widget < HTMLWidget

    # for some reason these need to be included in Widget and not AbstractWidget
    include Needs
    include Caching
    include Externals

    include HTML
    include Convenience
    include Erector::JQuery
    include Erector::Sass if Object.const_defined?(:Sass)

    # alias for AbstractWidget#render
    def to_html(options = {})
      raise "Erector::Widget#to_html takes an options hash, not a symbol. Try calling \"to_html(:content_method_name=> :#{options})\"" if options.is_a? Symbol
      _emit(options).to_s
    end

    # alias for #to_html
    # @deprecated Please use {#to_html} instead
    def to_s(*args)
      unless defined? @@already_warned_to_s
        $stderr.puts "Erector::Widget#to_s is deprecated. Please use #to_html instead. Called from #{caller.first}"
        @@already_warned_to_s = true
      end
      to_html(*args)
    end

  end
end
