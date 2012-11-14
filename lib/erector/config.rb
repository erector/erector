require 'active_support/core_ext/module/attribute_accessors'
module Erector

  # Rails specific configuration found in erector/rails/config

  # widget_class_name:: default superclass for generated/converted erector templates
  mattr_accessor :widget_class_name
  @@widget_class_name = 'Erector::Widget'

  # content_method_name:: content method used for rendering a widget
  #                       in case you want to call a method other than
  #                       #content, change its name in here.
  mattr_accessor :content_method
  @@content_method = :content

  #prettyprint:: whether Erector should add newlines and indentation.
  #               (false by default).
  mattr_accessor :prettyprint
  @@prettyprint = false

  # indentation:: the amount of spaces to indent. Ignored unless prettyprint
  #               is true.
  mattr_accessor :indentation
  @@indentation = 0

  # max_length:: preferred maximum length of a line. Line wraps will only
  #              occur at space characters, so a long word may end up
  #              creating a line longer than this. If nil (default), then
  #              there is no arbitrary limit to line lengths, and only
  #              internal newline characters and prettyprinting will
  #              determine newlines in the output.
  mattr_accessor :max_length
  @@max_length = nil

  def setup
    yield self
  end
end

