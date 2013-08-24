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
  #
  # It seems to me that SASS/SCSS should be part of the Page widget, which
  # would allow all the little style snippets to be compiled together
  # and appear in the document HEAD.
  module Sass
    def sass(arg, options = {})
      require "sass"
      options = {:cache => false}.merge(options)
      if arg =~ /[\w\.*]\.s?css/i
        options[:filename] = arg
        sass_text = File.read(arg)
      else
        sass_text = arg
      end
      style raw(::Sass.compile(sass_text, options))
    end

    def scss(arg, options = {})
      sass arg, {:syntax => :scss}.merge(options)
    end
  end
end
