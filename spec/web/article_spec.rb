here = File.dirname(__FILE__)
require File.expand_path("#{here}/../spec_helper")

$: << File.expand_path("#{here}/../../web/")
require "article"

describe Article do
  it "requires a name" do
    lambda {
      Article.new
    }.should raise_error(ArgumentError)

    a = Article.new(:name => "Foo")
    assert { a.instance_variable_get(:@name) == "Foo" }
  end
  
  it "renders a name" do
    a = Article.new(:name => "Foo")
    a.to_html.should == "<div class=\"article\"><h1 class=\"name\">Foo</h1></div>"
  end

  it "defaults to empty sections" do
    a = Article.new(:name => "Foo")
    assert { a.instance_variable_get(:@sections) == [] }
  end
  
  it "allows sections" do
    a = Article.new(:name => "Foo", :sections => [w = Erector::Widget.new])
    assert { a.instance_variable_get(:@sections) == [w] }
  end
  
  it "allows adding sections later" do
    a = Article.new(:name => "Foo")
    a << (w = Section.new(:name => "Bar"))
    assert { a.instance_variable_get(:@sections) == [w] }
  end
  
  it "returns self from <<, to allow chaining" do
    a = Article.new(:name => "Foo")
    val = a << (w = Erector::Widget.new)
    assert { val == a }
  end  
  
  it "allows adding sections via a method call" do
    a = Article.new(:name => "Foo")
    a.add(:name => "Bar") do
      p.bar!
    end
    s = a.instance_variable_get(:@sections)
    assert { s.size == 1 }
    assert { s.first.name == "Bar" }
    assert { s.first.to_html == "<p id=\"bar\"></p>" }
  end
  
  describe "with contents" do
    before do
      @article = Article.new(:name => "Gnome Plan")
      @article << Section.new(:name => "Steal Underpants") do
        p "very important"
      end

      @article << Section.new(:name => "?", :href => "question") do
        p "todo"
      end

      @article << Section.new(:name => "Profit!") do
        p "victory"
      end
    end
    
    it "shows a table of contents" do
      @article.to_html =~ /<div class=\"toc\">/
    end

    it "toc contains each section's name and a link to its href" do
      @article.to_html(:content_method_name => "table_of_contents", :prettyprint => true).should == <<-HTML
<div class="toc">
  <h2>Table of Contents</h2>
  <ol class="toc">
    <li><a href="#stealunderpants">Steal Underpants</a></li>
    <li><a href="#question">?</a></li>
    <li><a href="#profit">Profit!</a></li>
  </ol>
</div>
<div class="clear"></div>
      HTML
    end
    
    it "shows each section" do
      @article.to_html(:content_method_name => "emit_sections", :prettyprint => true).should == <<-HTML
<div class="sections">
  <a name="stealunderpants"></a>
  <h2>1. Steal Underpants</h2>
  <p>very important</p>
  <a name="question"></a>
  <h2>2. ?</h2>
  <p>todo</p>
  <a name="profit"></a>
  <h2>3. Profit!</h2>
  <p>victory</p>
</div>
      HTML
    end
  end
  
  describe "with subsections" do
    
    before do
      @article = Article.new(:name => "Food")
      @article << 
        Section.new(:name => "Breakfast") { p "very important" }.tap do |s|
           s << Section.new(:name => "Coffee") { p "french roast" }
           s << Section.new(:name => "Eggs") { p "scrambled" }
        end
    end
    
    it "toc contains each section's name and a link to its href" do
      @article.to_html(:content_method_name => "table_of_contents", :prettyprint => true).should == <<-HTML
<div class="toc">
  <h2>Table of Contents</h2>
  <ol class="toc">
    <li><a href="#breakfast">Breakfast</a>
      <ol class="toc">
        <li><a href="#coffee">Coffee</a></li>
        <li><a href="#eggs">Eggs</a></li>
      </ol>
    </li>
  </ol>
</div>
<div class="clear"></div>
      HTML
    end

    it "shows each section" do
      @article.to_html(:content_method_name => "emit_sections", :prettyprint => true).should == <<-HTML
<div class="sections">
  <a name="breakfast"></a>
  <h2>1. Breakfast</h2>
  <p>very important</p>
  <div class="sections">
    <a name="coffee"></a>
    <h3>1.1. Coffee</h3>
    <p>french roast</p>
    <a name="eggs"></a>
    <h3>1.2. Eggs</h3>
    <p>scrambled</p>
  </div>
</div>
      HTML
    end
  end
  
  it "can be created using nested taps and adds" do
    article = Article.new(:name => "food").tap { |a|
      a.add(:name => "fruit") {
        text "sweet and fibrous"
      }.tap { |s|
        s.add(:name => "apple") {
          text "crunchy"
        }.tap { |s|
          s.add(:name => "granny smith") {
            text "green"
          }
          s.add(:name => "red delicious") {
            text "red"
          }
        }
        s.add(:name => "banana") {
          text "yellow"
        }
      }
      a.add(:name => "bread") {
        text "chewy and grainy"
      }.tap { |s|
        s.add(:name => "sourdough") {
          text "tangy"
        }
      }
    }
    
    article.to_html(:prettyprint => true).should == <<-HTML
<div class="article">
  <h1 class="name">food</h1>
  <div class="toc">
    <h2>Table of Contents</h2>
    <ol class="toc">
      <li><a href="#fruit">fruit</a>
        <ol class="toc">
          <li><a href="#apple">apple</a>
            <ol class="toc">
              <li><a href="#grannysmith">granny smith</a></li>
              <li><a href="#reddelicious">red delicious</a></li>
            </ol>
          </li>
          <li><a href="#banana">banana</a></li>
        </ol>
      </li>
      <li><a href="#bread">bread</a>
        <ol class="toc">
          <li><a href="#sourdough">sourdough</a></li>
        </ol>
      </li>
    </ol>
  </div>
  <div class="clear"></div>
  <div class="sections">
    <a name="fruit"></a>
    <h2>1. fruit</h2>
    sweet and fibrous
    <div class="sections">
      <a name="apple"></a>
      <h3>1.1. apple</h3>
      crunchy
      <div class="sections">
        <a name="grannysmith"></a>
        <h4>1.1.1. granny smith</h4>
        green<a name="reddelicious"></a>
        <h4>1.1.2. red delicious</h4>
        red</div>
      <a name="banana"></a>
      <h3>1.2. banana</h3>
      yellow</div>
    <a name="bread"></a>
    <h2>2. bread</h2>
    chewy and grainy
    <div class="sections">
      <a name="sourdough"></a>
      <h3>2.1. sourdough</h3>
      tangy</div>
  </div>
</div>
    HTML
  end
end
