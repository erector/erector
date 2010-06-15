require File.expand_path("#{File.dirname(__FILE__)}/../spec_helper")
require 'benchmark'

module WidgetSpec
  describe Erector::Widget do
    include Erector::Mixin

    describe "#to_html" do
      it "invokes #content and returns the string representation of the rendered widget" do
        Class.new(Erector::Widget) do
          def content
            text "Hello"
          end
        end.new.to_html.should == "Hello"
      end

      it "supports other content methods via :content_method_name" do
        Class.new(Erector::Widget) do
          def alternate
            text "Alternate"
          end
        end.new.to_html(:content_method_name => :alternate).should == "Alternate"
      end

      it "returns an HTML-safe string" do
        Erector::Widget.new.to_html.should be_html_safe
      end

      it "accepts an existing string as an output buffer" do
        s = "foo"
        Erector.inline { text "bar" }.to_html(:output => s)
        s.should == "foobar"
      end

      it "accepts an existing Output as an output buffer" do
        output = Erector::Output.new
        output << "foo"
        Erector.inline { text "bar" }.to_html(:output => output)
        output.to_s.should == "foobar"
      end
    end

    describe "#to_a" do
      it "returns an array" do
        a = Erector.inline { div "Hello" }.to_a
        a.should be_an(Array)
        a.join.should == "<div>Hello</div>"
      end
    end

    describe '#widget' do
      class Orphan < Erector::Widget
        def content
          p @name
        end
      end

      it "renders a widget class" do
        erector do
          div do
            widget Orphan, :name => "Annie"
          end
        end.should == "<div><p>Annie</p></div>"
      end

      it "renders a widget instance" do
        erector do
          div do
            widget Orphan.new(:name => "Oliver")
          end
        end.should == "<div><p>Oliver</p></div>"
      end

      it "adds the widget to the parent's output widgets" do
        inner = Class.new(Erector::Widget)
        outer = Erector.inline { widget inner }
        outer.to_html
        outer.output.widgets.should include(inner)
      end

      it "supports specifying content_method_name" do
        inner = Class.new(Erector::Widget) do
          def foo; text "foo"; end
        end
        erector do
          widget inner, {}, :content_method_name => :foo
        end.should == "foo"
      end

      it "renders nested widgets in the correct order" do
        class Parent < Erector::Widget
          def content
            text 1
            widget Erector::Widget do
              text 2
              third
            end
          end

          def third
            text 3
          end
        end

        Parent.new.to_html.should == '123'
      end

      context "when nested" do
        module WhenNested
          class Parent < Erector::Widget
            def content
              div :id => "parent_widget" do
                super
              end
            end
          end

          class Child < Erector::Widget
            def content
              div :id => "child_widget" do
                super
              end
            end
          end

          class Grandchild < Erector::Widget
            needs :parent_widget, :child_widget
            def content
              widget(@parent_widget) do
                widget(@child_widget) do
                  div :id => "grandchild"
                end
              end
            end
          end
        end

        it "renders the tag around the rest of the block" do
          WhenNested::Grandchild.new(
                  :parent_widget => WhenNested::Parent,
                  :child_widget => WhenNested::Child
          ).to_html.should == '<div id="parent_widget"><div id="child_widget"><div id="grandchild"></div></div></div>'
        end

        it "renders the tag around the rest of the block with proper indentation" do
          WhenNested::Grandchild.new(
                  :parent_widget => WhenNested::Parent,
                  :child_widget => WhenNested::Child
          ).to_pretty.should ==
                  "<div id=\"parent_widget\">\n" +
                          "  <div id=\"child_widget\">\n" +
                          "    <div id=\"grandchild\"></div>\n" +
                          "  </div>\n" +
                          "</div>\n"
        end

        it "passes a pointer to the child object back into the parent object's block" do
          child_widget = Erector::Widget.new

          class Parent2 < Erector::Widget
            needs :child_widget
            def content
              div do
                widget @child_widget do |child|
                  b child.dom_id
                end
              end
            end
          end

          Parent2.new(:child_widget => child_widget).to_html.should == "<div><b>#{child_widget.dom_id}</b></div>"
        end
      end
    end

    describe "#call_block" do
      it "calls the block with a pointer to self" do
        inside_arg = nil
        inside_self = nil
        x = Erector::Widget.new do |y|
          inside_arg = y.object_id
          inside_self = self.object_id
        end
        x.call_block
        # inside the block...
        inside_arg.should == x.object_id # the argument is the child
        inside_self.should == self.object_id # and self is the parent
      end
    end

    describe '#capture' do
      it "should return content rather than write it to the buffer" do
        erector do
          captured = capture do
            p 'Captured Content'
          end
          div do
            text captured
          end
        end.should == '<div><p>Captured Content</p></div>'
      end

      it "returns a RawString" do
        captured = nil
        erector do
          captured = capture {}
        end.should == ""
        captured.should be_a_kind_of(Erector::RawString)
      end

      it "works with nested captures" do
        erector do
          captured = capture do
            captured = capture do
              p 'Nested Capture'
            end
            p 'Captured Content'
            text captured
          end
          div do
            text captured
          end
        end.should == '<div><p>Captured Content</p><p>Nested Capture</p></div>'
      end
    end

    describe '#text' do
      it "renders a widget" do
        erector do
          text "B"
          text Erector.inline { p "A" }
          text "B"
        end.should == "B<p>A</p>B"
      end
    end

    describe "assigning instance variables" do
      it "handles instance variable names with and without '@' in the beginning" do
        html = Erector.inline(:foo => "bar", '@baz' => 'quux') do
          div do
            p @foo
            p @baz
          end
        end.to_html
        doc = Nokogiri::HTML(html)
        doc.css("p").map {|p| p.inner_html}.should == ["bar", "quux"]
      end
    end
  end
end
