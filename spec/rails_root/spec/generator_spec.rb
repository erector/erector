require File.expand_path("#{File.dirname(__FILE__)}/rails_spec_helper")

describe Erector::Rails::Generators::ConfigGenerator do
  include GenSpec::GeneratorExampleGroup # we need to include explicitly due to unorthodox file path
  it "should generate a initializer" do
    subject.should generate("config/initializers/erector.rb") do |content|
      content[/[^\n]+\n/].should == "Erector.setup do |config|\n"
    end
  end

end
