require File.expand_path("#{File.dirname(__FILE__)}/../spec_helper")

describe Erector::Caching do
  include Erector::Mixin

  class Cash < Erector::Widget
    needs :name
    cachable
    def content
      p do
        text @name
        text " Cash"
      end
    end
  end

  class Family < Erector::Widget
    cacheable
    def content
      widget Cash, :name => "Johnny"
      widget Cash, :name => "June"
    end
  end

  class NotCachable < Erector::Widget
    def content
      text "CONTENT"
    end
  end

  before do
    @cache = Erector::Cache.new
    Erector::Widget.cache = @cache
  end

  after do
    Erector::Widget.cache = nil
  end

  it "has a global cache" do
    Erector::Widget.cache.should == @cache
  end

  it '-- a widget is not cachable by default' do
    Erector::Widget.cachable?.should be_false
  end

  it '-- a widget is cachable if you say so in the class definition' do
    Cash.cachable?.should be_true
  end

  it '-- can be declared cachable using the alternate spelling "cacheable"' do
    Family.cachable?.should be_true
  end

  describe '#to_s' do

    it "caches a rendered widget" do
      Cash.new(:name => "Johnny").to_s
      @cache[Cash, {:name => "Johnny"}].should == "<p>Johnny Cash</p>"
    end

    it "uses the cached value" do
      @cache[Cash, {:name => "Johnny"}] = "CACHED"
      Cash.new(:name => "Johnny").to_s.should == "CACHED"
    end

    it "doesn't use the cached value for widgets not declared cachable" do
      @cache[NotCachable] = "CACHED"
      NotCachable.new.to_s.should == "CONTENT"
    end

    it "doesn't cache widgets not declared cachable" do
      NotCachable.new.to_s
      @cache[NotCachable].should be_nil
    end

    it "doesn't cache widgets initialized with a block (yet)" do
      Cash.new(:name => "June") do
        text "whatever"
      end.to_s
      @cache[Cash, {:name => "June"}].should be_nil
    end

    it "works when passing an existing output as a parameter to to_s"
  end

  describe '#widget' do

    it "caches rendered widgets" do
      Family.new.to_s
      @cache[Cash, {:name => "Johnny"}].should == "<p>Johnny Cash</p>"
      @cache[Cash, {:name => "June"}].should == "<p>June Cash</p>"
    end

    it "uses the cached value" do
      @cache[Cash, {:name => "Johnny"}] = "JOHNNY CACHED"
      Family.new.to_s.should == "JOHNNY CACHED<p>June Cash</p>"
    end

    class WidgetWithBlock < Erector::Widget
      def content
        call_block
      end
    end

    it "doesn't cache widgets initialized with a block (yet)" do
      erector {
        w = WidgetWithBlock.new do
          text "in block"
        end
        widget w
      }.should == "in block"
      @cache[WidgetWithBlock].should be_nil
    end

  end
end
