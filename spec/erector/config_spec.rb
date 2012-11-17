require File.expand_path("#{File.dirname(__FILE__)}/../spec_helper")

describe Erector do

  SETTINGS = {
      :widget_class_name       => 'Erector::Widget',
      :content_method          => :content,
      :prettyprint             => false,
      :indentation             => 0,
      :max_length              => nil,
      :add_accessors_for_needs => false,
      :widget_class_prefix     => "views"
  }

  SETTINGS.each { |s, v| test_default(s, v) }

end