module Erector
  # Adds sass support to Erector widgets.
  #
  # Sass is an *optional dependency* of the Erector gem, so
  # a call to +sass+ inside a widget will fail unless you have already
  # installed the sass gem (e.g. "gem 'sass'" in your code or Gemfile).
  #
  # Current support is barebones. Please offer suggestions (or better
  # yet, patches) for whether and how to support, e.g., caching,
  # loading from files, precompilation, etc.
  module Sass
    def sass(sass_text)
      require "sass"
      style ::Sass::Engine.new(sass_text, :cache => false).render
    end
  end
end
