require File.expand_path("#{File.dirname(__FILE__)}/../../spec_helper")

module Erector
  module Widgets
    describe Page do
      it "works" do
        Page.new.to_s
      end
    end
  end
end
