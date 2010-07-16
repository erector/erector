require File.expand_path("#{File.dirname(__FILE__)}/../spec_helper")

  describe Erector::Cache do
    before do
      @cache = Erector::Cache.new
    end

    class Johnny < Erector::Widget
    end

    class June < Erector::Widget
    end

    it 'caches a class with no parameters' do
      @cache[Johnny] = "ring of fire"
      @cache[Johnny].should == "ring of fire"
    end

    it 'caches two classes with no parameters' do
      @cache[Johnny] = "ring of fire"
      @cache[June] = "wildwood flower"
      @cache[Johnny].should == "ring of fire"
      @cache[June].should == "wildwood flower"
    end

    it "stores different slots for the same class with different parameters" do
      @cache[Johnny, {:flames => "higher"}] = "ring of fire"
      @cache[Johnny, {:working => "in a coal mine"}] = "my daddy died young"

      @cache[Johnny, {:flames => "higher"}].should == "ring of fire"
      @cache[Johnny, {:working => "in a coal mine"}].should == "my daddy died young"
    end

    it "stores different slots for the same class with same parameters and different content methods" do
      @cache[Johnny, {}, :foo] = "ring of fire"
      @cache[Johnny, {}, :bar] = "my daddy died young"

      @cache[Johnny, {}, :foo].should == "ring of fire"
      @cache[Johnny, {}, :bar].should == "my daddy died young"
    end

    describe 'after storing a widget with one parameter' do
      before do
        @cache[Johnny, {:flames => "higher"}] = "ring of fire"
      end

      it 'doesn\'t get it when passed the class alone' do
        @cache[Johnny].should be_nil
      end

      it 'doesn\'t get it when passed a different class' do
        @cache[June].should be_nil
      end

      it 'gets it' do
        @cache[Johnny, {:flames => "higher"}].should == "ring of fire"
      end

      it 'doesn\'t get it when passed a different parameter key' do
        @cache[Johnny, {:working => "coal mine"}].should be_nil
      end

      it 'doesn\'t get it when passed a different parameter value' do
        @cache[Johnny, {:flames => "lower"}].should be_nil
      end

      it 'doesn\'t get it when passed an extra parameter key' do
        @cache[Johnny, {:flames => "higher", :working => "coal mine"}].should be_nil
      end
    end

    describe 'after storing a widget with more than one parameter' do
      before do
        @cache[Johnny, {:flames => "higher", :working => "coal mine"}] = "ring of fire"
      end

      it "gets it" do
        @cache[Johnny, {:flames => "higher", :working => "coal mine"}].should == "ring of fire"
      end

      it 'doesn\'t get it when passed the class alone' do
        @cache[Johnny].should be_nil
      end

      it "doesn't get it when passed a partial parameter set" do
        @cache[Johnny, {:flames => "higher"}].should be_nil
      end

      it 'doesn\'t get it when passed a different class' do
        @cache[June].should be_nil
      end

      it 'doesn\'t get it when passed different a parameter value' do
        @cache[Johnny, {:flames => "lower", :working => "coal mine"}].should be_nil
      end

      it 'doesn\'t get it when passed an extra parameter key' do
        @cache[Johnny, {:flames => "higher", :working => "coal mine", :hear => "train a' comin'"}].should be_nil
      end
    end

    describe "expires" do
      it 'a class with no parameters' do
        @cache[Johnny] = "ring of fire"
        @cache.delete(Johnny)
        @cache[Johnny].should be_nil
      end

      it 'all versions of a class' do
        @cache[Johnny] = "i fell in"
        @cache[Johnny, {:flames => "higher"}] = "ring of fire"
        @cache[Johnny, {:working => "in a coal mine"}] = "my daddy died young"

        @cache.delete_all(Johnny)

        @cache[Johnny].should be_nil
        @cache[Johnny, {:flames => "higher"}].should be_nil
        @cache[Johnny, {:working => "in a coal mine"}].should be_nil
      end

      it '...but not other cached values' do
        @cache[Johnny] = "ring of fire"
        @cache[Johnny, {:flames => 'higher'}] = "higher fire"
        @cache[June] = "wildwood flower"
        @cache.delete(Johnny)
        @cache[Johnny].should be_nil
        @cache[Johnny, {:flames => 'higher'}].should == "higher fire"
        @cache[June].should == "wildwood flower"
      end
    end
  end

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

    describe '#to_html' do

      it "caches a rendered widget" do
        Cash.new(:name => "Johnny").to_html
        @cache[Cash, {:name => "Johnny"}].to_s.should == "<p>Johnny Cash</p>"
      end

      it "uses the cached value" do
        @cache[Cash, {:name => "Johnny"}] = "CACHED"
        Cash.new(:name => "Johnny").to_html.should == "CACHED"
      end

      it "doesn't use the cached value for widgets not declared cachable" do
        @cache[NotCachable] = "CACHED"
        NotCachable.new.to_html.should == "CONTENT"
      end

      it "doesn't cache widgets not declared cachable" do
        NotCachable.new.to_html
        @cache[NotCachable].should be_nil
      end

      it "doesn't cache widgets initialized with a block (yet)" do
        Cash.new(:name => "June") do
          text "whatever"
        end.to_html
        @cache[Cash, {:name => "June"}].should be_nil
      end

      it "caches distinct values when using :content_method_name" do
        widget = Class.new(Erector::Widget) do
          cacheable

          def foo
            text "foo"
          end

          def bar
            text "bar"
          end
        end

        widget.new.to_html(:content_method_name => :foo).should == "foo"
        widget.new.to_html(:content_method_name => :bar).should == "bar"
      end

      it "works when passing an existing output as a parameter to to_html" do
        pending
      end
    end

    describe '#widget' do

      it "caches rendered widgets" do
        Family.new.to_html
        @cache[Cash, {:name => "Johnny"}].to_s.should == "<p>Johnny Cash</p>"
        @cache[Cash, {:name => "June"}].to_s.should == "<p>June Cash</p>"
      end

      it "uses the cached value" do
        @cache[Cash, {:name => "Johnny"}] = "JOHNNY CACHED"
        Family.new.to_html.should == "JOHNNY CACHED<p>June Cash</p>"
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
