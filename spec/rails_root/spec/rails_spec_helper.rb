ENV["RAILS_ENV"] ||= "test"
ENV["BUNDLE_GEMFILE"] ||= "#{File.dirname(__FILE__)}/../Gemfile"

require File.expand_path("../../../spec_helper", __FILE__)
require File.expand_path("../../config/environment", __FILE__)

Bundler.require(:test)

require "erector/rails"

class BaseDummyModel
  # see http://gist.github.com/191263
  def self.self_and_descendants_from_active_record
    [self]
  end

  def self.human_attribute_name(attribute_key_name, options = {})
    defaults = self_and_descendants_from_active_record.map do |klass|
      "#{klass.name.underscore}.#{attribute_key_name}""#{klass.name.underscore}.#{attribute_key_name}"
    end
    defaults << options[:default] if options[:default]
    defaults.flatten!
    defaults << attribute_key_name.humanize
    options[:count] ||= 1
    I18n.translate(defaults.shift, options.merge(:default => defaults, :scope => [:activerecord, :attributes]))
  end

  def self.human_name(options = {})
    defaults = self_and_descendants_from_active_record.map do |klass|
      "#{klass.name.underscore}""#{klass.name.underscore}"
    end
    defaults << self.name.humanize
    I18n.translate(defaults.shift, {:scope => [:activerecord, :models], :count => 1, :default => defaults}.merge(options))
  end
end
