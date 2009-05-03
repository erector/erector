# One can use methods to create custom view components, in this
# example Blocks and Block.  Blocks for us are essentially Unordered list wrappers
# with custom styling.  A Block is a container that has a few
# sections like a Title, and Behaviors plus the body etc.

# Compare with blocks-via-widget.rb.

require "#{File.dirname(__FILE__)}/../lib/erector"

class Overall < Erector::Widget

  def username
    "bob"
  end

  def blocks
    ul :class => "blocks" do
      yield
    end
  end

  def block(args = {})
    li do
      h1 args[:title]
      div :class => args[:behaviors] do
        yield
      end
    end
  end

  def content
    blocks do
      block :title => "Block 1", :behaviors => 'buttons' do
        p "my crazy blocks example for #{username}"
      end
      block :title => "Block 2", :behaviors => 'other_buttons' do
        div do
          text "and here is another"
          span "crazy block"
        end
      end
    end
  end
  
end

puts Overall.new().to_s

