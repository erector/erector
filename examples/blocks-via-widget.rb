# The #widget method is for creating custom view components, in this
# example Blocks and Block.  Blocks for us are essentially Unordered list wrappers
# with custom styling.  A Block is a container that has a few
# sections like a Title, and Behaviors plus the body etc.

# Compare with blocks-via-method.rb (which, in this example, is the
# more straightforward solution, but which may or may not be applicable
# to more complicated situations).

require "#{File.dirname(__FILE__)}/../lib/erector"

class Blocks < Erector::Widget
  def content
    ul :class => "blocks" do
      super # the parent method will render the block you passed in to new
    end
  end
end

class Block < Erector::Widget
  def content
    li do
      h1 @title
      div :class => @behaviors do
        super # the parent method will render the block you passed in to new
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

