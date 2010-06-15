# One can use methods to create custom view components, in this
# example Chunks and Chunk.  Chunks for us are essentially Unordered list wrappers
# with custom styling.  A Chunk is a container that has a few
# sections like a Title, and Behaviors plus the body etc.

# Compare with chunks-via-widget.rb.

require "#{File.dirname(__FILE__)}/../lib/erector"

class Overall < Erector::Widget

  def username
    "bob"
  end

  def chunks
    ul :class => "chunks" do
      yield
    end
  end

  def chunk(args = {})
    li do
      h1 args[:title]
      div :class => args[:behaviors] do
        yield
      end
    end
  end

  def content
    chunks do
      chunk :title => "Chunk 1", :behaviors => 'buttons' do
        p "my crazy chunks example for #{username}"
      end
      chunk :title => "Chunk 2", :behaviors => 'other_buttons' do
        div do
          text "and here is another"
          span "crazy chunk"
        end
      end
    end
  end
  
end

puts Overall.new().to_html

