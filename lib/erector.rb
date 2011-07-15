module Erector
end

require "cgi"
require "yaml"
begin
  require "sass"
rescue LoadError => e
  # oh well, no Sass
end

require "erector/errors"
require "erector/extensions/object"
require "erector/extensions/hash"
require "erector/raw_string"
require "erector/dependencies"
require "erector/dependency"
require "erector/externals"
require "erector/output"
require "erector/caching"
require "erector/after_initialize"
require "erector/needs"
require "erector/html"
require "erector/convenience"
require "erector/jquery"
require "erector/sass"
require "erector/abstract_widget"
require "erector/widget"

require "erector/inline"
require "erector/unicode"
require "erector/widgets"
require "erector/version"
require "erector/mixin"

require "erector/rails" if defined?(Rails)
