# The #widget method is for creating custom view components, in this
# example Blocks and Block.  Blocks for us are essentially Unordered list wrappers
# with custom styling.  A Block is a container that has a few
# sections like a Title, and Behaviors plus the body etc.

# Compare with blocks-via-method.rb (which, in this example, is the
# more straightforward solution, but which may or may not be applicable
# to more complicated situations).

dir = File.expand_path(File.dirname(__FILE__))
$LOAD_PATH.unshift("#{dir}/../lib")
require 'erector'

class Blocks < Erector::Widget
  def render
    ul :class => "blocks" do
      super
    end
  end
end

class Block < Erector::Widget
  def render
    li do
      h1 @title
      div :class => @behaviors do
        super
      end
    end
  end
end

overall = Erector::Widget.new do

  def username
    "bob"
  end

  widget Blocks do
    widget Block, :title => "Block 1", :behaviors => 'buttons' do
      p "my crazy blocks example for #{username}"
    end
    widget Block, :title => "Block 2", :behaviors => 'other_buttons' do
      div do
        text "and here is another"
        span "crazy block"
      end
    end
  end
  
end

puts overall.to_s

