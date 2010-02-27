ENV["RAILS_ENV"] ||= "test"
dir = File.dirname(__FILE__)
$LOAD_PATH.unshift("#{dir}/../../../lib")
require "#{dir}/../config/environment"

require "action_controller/test_process"
ARGV.push(*File.read("#{File.dirname(__FILE__)}/../../spec.opts").split("\n"))
require "spec"
require "spec/autorun"
require "nokogiri"
require "rr"
require "rr/adapters/rspec"
require 'treetop'
require "erector"
require "erector/erect/erect"
require "erector/erect/erected"

Spec::Runner.configure do |config|
  config.mock_with RR::Adapters::Rspec
end

unless '1.9'.respond_to?(:force_encoding)
  String.class_eval do
    begin
      remove_method :chars
    rescue NameError
      # OK
    end
  end
end

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
