require 'spec_helper'

class AfterInitializeWidget < Erector::Widget

  after_initialize do
    @foo ||= ''
    @foo += 'bar'
  end

  def content
    html do
      head do
        title "Welcome page"
      end
      body do
        p @foo
      end
    end
  end
end

class AfterInitializeWidgetTwo < AfterInitializeWidget
end

class AfterInitializeWidgetThree < AfterInitializeWidget
  after_initialize do
    @foo += 'baz'
  end
end

describe Erector::AfterInitialize do

  it 'should call the block' do
    AfterInitializeWidget.new.to_html.should == %Q{<html><head><title>Welcome page</title></head><body><p>bar</p></body></html>}
  end

  it 'should call the block only once' do
    AfterInitializeWidgetTwo.new.to_html.should == %Q{<html><head><title>Welcome page</title></head><body><p>bar</p></body></html>}
  end

  it 'should call each block' do
    AfterInitializeWidgetThree.new.to_html.should == %Q{<html><head><title>Welcome page</title></head><body><p>barbaz</p></body></html>}
  end

end
