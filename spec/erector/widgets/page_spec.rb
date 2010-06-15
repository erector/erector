require File.expand_path("#{File.dirname(__FILE__)}/../../spec_helper")

describe Erector::Widgets::Page do
  it "works" do
    Erector::Widgets::Page.new.to_html
  end

  it "renders body_content" do
    Class.new(Erector::Widgets::Page) do
      def body_content
        text "body_content"
      end
    end.new.to_html.should =~ /body_content/
  end

  it "renders a block passed to new" do
    Erector::Widgets::Page.new do
      text "nice bod"
    end.to_html.should =~ /nice bod/
  end

  it "renders a block passed to content" do
    Class.new(Erector::Widgets::Page) do
      def content
        super do
          text "body_content"
        end
      end
    end.new.to_html.should =~ /body_content/
  end

  it "allows subclasses to provide a css class for the body" do
    Class.new(Erector::Widgets::Page) do
      def body_attributes
        {:class => "funky"}
      end
    end.new.to_html.should =~ /<body class=\"funky\">/
  end

  it "allows subclasses to be called with a block" do
    fun_page_class = Class.new(Erector::Widgets::Page) do
      def body_content
        h3 "what's fun?"
        call_block
      end
    end
    fun_page_class.new do
      text "soccer!"
    end.to_html.should include("<h3>what's fun?</h3>soccer!")
  end

  class NiceWidget < Erector::Widget
    external :style, ".nice {}"
    def content
      text "nice widget"
    end
  end
  class MeanWidget < Erector::Widget
    external :style, ".mean {}"
  end

  class NicePage < Erector::Widgets::Page
    def body_content
      text "nice page"
      widget NiceWidget
    end
  end

  class MeanPage < Erector::Widgets::Page
    def body_content
      widget MeanWidget
    end
  end

  it "only puts into dependencies those from widgets rendered on it" do
    s = NicePage.new.to_html
    s.should include("nice page")
    s.should include("nice widget")
    s.should include(".nice {}")
    s.should_not include(".mean {}")

    MeanPage.new.to_html.should include(".mean {}")
    MeanPage.new.to_html.should_not include(".nice {}")
  end
end
