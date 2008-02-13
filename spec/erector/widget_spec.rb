require File.expand_path("#{File.dirname(__FILE__)}/../spec_helper")

module WidgetSpec
  describe Erector::Widget do
    describe ".all_tags" do
      it "returns set of full and standalone tags" do
        Erector::Widget.all_tags.class.should == Array
        Erector::Widget.all_tags.should == Erector::Widget.full_tags + Erector::Widget.standalone_tags
      end
    end

    describe "#instruct!" do
      it "when passed no arguments; returns an instruct element with version 1 and utf-8" do
        html = Erector::Widget.new do
          instruct!
        end.to_s
        html.should include("<?xml")
        html.should include('encoding="UTF-8"')
        html.should include('version="1.0')
        html.should include("?>")
      end
    end

    describe "#element" do
      it "when receiving one argument; returns an empty element" do
        Erector::Widget.new do
          element('div')
        end.to_s.should == "<div></div>"
      end

      it "with a attribute hash; returns an empty element with the attributes" do
        html = Erector::Widget.new do
          element(
            'div',
              :class => "foo bar",
              :style => "display: none; color: white; float: left;",
              :nil_attribute => nil
          )
        end.to_s
        doc = Hpricot(html)
        div = doc.at('div')
        div[:class].should == "foo bar"
        div[:style].should == "display: none; color: white; float: left;"
        div[:nil_attribute].should be_nil
      end

      it "with inner tags; returns nested tags" do
        widget = Erector::Widget.new do
          element 'div' do
            element 'div'
          end
        end
        widget.to_s.should == '<div><div></div></div>'
      end

      it "with text; returns element with inner text" do
        Erector::Widget.new do
          element 'div', 'test text'
        end.to_s.should == "<div>test text</div>"
      end

      it "with object other than hash; returns element with inner text == object.to_s" do
        object = ['a', 'b']
        Erector::Widget.new do
          element 'div', object
        end.to_s.should == "<div>#{object.to_s}</div>"
      end

      it "with parameters and block; returns element with inner html and attributes" do
        Erector::Widget.new do
          element 'div', 'class' => "foobar" do
            element 'span', 'style' => 'display: none;'
          end
        end.to_s.should == '<div class="foobar"><span style="display: none;"></span></div>'
      end

      it "with content and parameters; returns element with content as inner html and attributes" do
        Erector::Widget.new do
          element 'div', 'test text', :style => "display: none;"
        end.to_s.should == '<div style="display: none;">test text</div>'
      end

      it "with more than three arguments; raises ArgumentError" do
        proc do
          Erector::Widget.new do
            element 'div', 'foobar', {}, 'fourth'
          end.to_s
        end.should raise_error(ArgumentError)
      end

      it "renders the proper full tags" do
        Erector::Widget.full_tags.each do |tag_name|
          expected = "<#{tag_name}></#{tag_name}>"
          actual = Erector::Widget.new do
            send(tag_name)
          end.to_s
          begin
            actual.should == expected
          rescue Spec::Expectations::ExpectationNotMetError => e
            puts "Expected #{tag_name} to be a full element. Expected #{expected}, got #{actual}"
            raise e
          end
        end
      end
    end

    describe "#standalone_element" do
      it "when receiving attributes, renders a standalone_element with the attributes" do
        Erector::Widget.new do
          standalone_element 'input', :name => 'foo[bar]'
        end.to_s.should == '<input name="foo[bar]" />'
      end

      it "when not receiving attributes, renders a standalone_element without attributes" do
        Erector::Widget.new do
          standalone_element 'br'
        end.to_s.should == '<br />'
      end

      it "renders the proper standalone tags" do
        ['area', 'base', 'br', 'hr', 'img', 'input', 'link', 'meta'].each do |tag_name|
          expected = "<#{tag_name} />"
          actual = Erector::Widget.new do
            send(tag_name)
          end.to_s
          begin
            actual.should == expected
          rescue Spec::Expectations::ExpectationNotMetError => e
            puts "Expected #{tag_name} to be a standalone element. Expected #{expected}, got #{actual}"
            raise e
          end
        end
      end
    end

    describe "#javascript" do
      it "when receiving a block; renders the content inside of a script text/javascript element" do
        body = Erector::Widget.new do
          javascript do
            text 'alert("hello");'
          end
        end.to_s
        doc = Hpricot(body)
        script_tag = doc.at("script")
        script_tag[:type].should == "text/javascript"
        script_tag.inner_html.should include('alert("hello");')
      end

      it "when receiving a params hash; renders a source file" do
        html = Erector::Widget.new do
          javascript(:src => "/my/js/file.js")
        end.to_s
        doc = Hpricot(html)
        doc.at('/')[:src].should == "/my/js/file.js"
      end

      it "when receiving text and a params hash; renders a source file" do
        html = Erector::Widget.new do
          javascript('alert("hello");', :src => "/my/js/file.js")
        end.to_s
        doc = Hpricot(html)
        script_tag = doc.at('script')
        script_tag[:src].should == "/my/js/file.js"
        script_tag.inner_html.should include('alert("hello");')
      end
    end

    describe '#capture' do
      it "should return content rather than write it to the buffer" do
        widget = Erector::Widget.new do
          captured = capture do
            p 'Captured Content'
          end
          div do
            text captured
          end
        end
        widget.to_s.should == '<div><p>Captured Content</p></div>'
      end

      it "works with nested captures" do
        widget = Erector::Widget.new do
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
        end
        widget.to_s.should == '<div><p>Captured Content</p><p>Nested Capture</p></div>'
      end
    end

    describe '#widget' do
      before do
        class Parent < Erector::Widget
          def render
            text 1
            widget Child do
              text 2
              third
            end
          end

          def third
            text 3
          end
        end

        class Child < Erector::Widget
          def render
            super
          end
        end
      end

      it "renders nested widgets in the correct order" do
        Parent.new.to_s.should == '123'
      end
    end
  end
end
