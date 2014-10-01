require 'spec_helper'

# todo: figure out why "include Caching" only works when it's on Widget
describe Erector::Cache do
  before do
    ::Rails.cache.clear
    @cache = Erector::Cache.instance
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

      ::Rails.cache.clear

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
