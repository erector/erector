require File.expand_path("#{File.dirname(__FILE__)}/../../spec_helper")

describe Erector::Widgets::Page do
  it "works" do
    Erector::Widgets::Page.new.to_s
  end

  it "renders body_content" do
    Class.new(Erector::Widgets::Page) do
      def body_content
        text "body_content"
      end
    end.new.to_s.should =~ /body_content/
  end

  it "renders a block passed to new" do
    Erector::Widgets::Page.new do
      text "body_content"
    end.to_s.should =~ /body_content/
  end

  it "renders a block passed to content" do
    Class.new(Erector::Widgets::Page) do
      def content
        super do
          text "body_content"
        end
      end
    end.new.to_s.should =~ /body_content/
  end

  it "allows subclasses to provide a css class for the body" do
    Class.new(Erector::Widgets::Page) do
      def body_attributes
        {:class => "funky"}
      end
    end.new.to_s.should =~ /<body class=\"funky\">/
  end
end
