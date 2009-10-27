require File.expand_path("#{File.dirname(__FILE__)}/../../spec_helper")

module Erector
  module Widgets
    describe Page do
      it "works" do
        Page.new.to_s
      end
      
      class FunkyPage < Page
        def body_attributes
          {:class => "funky"}
        end
      end

      it "allows subclasses to provide a css class for the body" do
        FunkyPage.new.to_s.should =~ /<body class=\"funky\">/
      end
    end
  end
end
