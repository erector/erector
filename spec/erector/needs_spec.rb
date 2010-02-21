require File.expand_path("#{File.dirname(__FILE__)}/../spec_helper")

describe Erector::Needs do
  it "doesn't complain if there aren't any needs declared" do
    class Thing1 < Erector::Widget
    end
    Thing1.new
  end

  it "allows you to say that you don't want any parameters" do
    class Thing2 < Erector::Widget
      needs nil
    end
    lambda { Thing2.new }.should_not raise_error
    lambda { Thing2.new(:foo => 1) }.should raise_error
  end

  it "doesn't complain if you pass it a declared parameter" do
    class Thing2b < Erector::Widget
      needs :foo
    end
    lambda { Thing2b.new(:foo => 1) }.should_not raise_error
  end

  it "complains if you pass it an undeclared parameter" do
    class Thing3 < Erector::Widget
      needs :foo
    end
    lambda { Thing3.new(:bar => 1) }.should raise_error
  end

  it "allows multiple declared parameters" do
    class Thing4 < Erector::Widget
      needs :foo, :bar
    end
    lambda { Thing4.new(:foo => 1, :bar => 2) }.should_not raise_error
  end

  it "complains when passing in an extra parameter after declaring many parameters" do
    class Thing5 < Erector::Widget
      needs :foo, :bar
    end
    lambda { Thing5.new(:foo => 1, :bar => 2, :baz => 3) }.should raise_error
  end

  it "complains when you forget to pass in a needed parameter" do
    class Thing6 < Erector::Widget
      needs :foo, :bar
    end
    lambda { Thing6.new(:foo => 1) }.should raise_error
  end

  it "doesn't complain if you omit a parameter with a default value" do
    class Thing7 < Erector::Widget
      needs :foo
      needs :bar => 7
      needs :baz => 8
    end
    lambda {
      thing = Thing7.new(:foo => 1, :baz => 3)
      thing.instance_variable_get(:@bar).should equal(7)
      thing.instance_variable_get(:@baz).should equal(3)
    }.should_not raise_error
  end

  it "allows multiple values on a line, including default values at the end of the line" do
    class Thing8 < Erector::Widget
      needs :foo, :bar => 7, :baz => 8
    end
    lambda {
      thing = Thing8.new(:foo => 1, :baz => 2)
      thing.instance_variable_get(:@foo).should equal(1)
      thing.instance_variable_get(:@bar).should equal(7)
      thing.instance_variable_get(:@baz).should equal(2)
    }.should_not raise_error
  end

  it "allows nil to be a default value" do
    class Thing9 < Erector::Widget
      needs :foo => nil
    end
    lambda {
      thing = Thing9.new
      thing.instance_variable_get(:@foo).should be_nil
    }.should_not raise_error
  end

  it "accumulates needs across the inheritance chain even with modules mixed in" do
    module Something
    end

    class Vehicle < Erector::Widget
      needs :wheels
    end

    class Car < Vehicle
      include Something
      needs :engine
    end

    lambda { Car.new(:engine => 'V-8', :wheels => 4) }.should_not raise_error
    lambda { Car.new(:engine => 'V-8') }.should raise_error
    lambda { Car.new(:wheels => 4) }.should raise_error
  end

  it "no longer defines accessors for each of the needed variables" do
    class NeedfulThing < Erector::Widget
      needs :love
    end
    thing = NeedfulThing.new(:love => "all we need")
    lambda {thing.love}.should raise_error(NoMethodError)
  end

  it "no longer complains if you attempt to 'need' a variable whose name overlaps with an existing method" do
    class ThingWithOverlap < Erector::Widget
      needs :text
    end
    lambda { ThingWithOverlap.new(:text => "alas") }.should_not raise_error(ArgumentError)
  end
end
