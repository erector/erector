here = File.expand_path(File.dirname(__FILE__))
require File.expand_path("#{here}/../spec_helper")

describe "Hello World example from README" do
  it "works" do
    Dir.chdir('/tmp') do
      clear_bundler_env
      html = `ruby #{File.join(here,'hello_from_readme.rb')} 2>&1`
      html.should == "<html><head><title>Welcome page</title></head><body><p>Hello, world</p></body></html>\n"
    end
  end
end
