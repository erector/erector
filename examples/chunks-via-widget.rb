# The #widget method is for creating custom view components, in this
# example Chunks and Chunk.  Chunks for us are essentially Unordered list wrappers
# with custom styling.  A Chunk is a container that has a few
# sections like a Title, and Behaviors plus the body etc.

# Compare with chunks-via-method.rb (which, in this example, is the
# more straightforward solution, but which may or may not be applicable
# to more complicated situations).

require "#{File.dirname(__FILE__)}/../lib/erector"

class Chunks < Erector::Widget
  def content
    ul :class => "chunks" do
      super # the parent method will render the chunk you passed in to new
    end
  end
end

class Chunk < Erector::Widget
  def content
    li do
      h1 @title
      div :class => @behaviors do
        super # the parent method will render the chunk you passed in to new
      end
    end
  end
end

overall = Erector.inline do

  def username
    "bob"
  end

  widget Chunks do
    widget Chunk, :title => "Chunk 1", :behaviors => 'buttons' do
      p "my crazy chunks example for #{username}"
    end
    widget Chunk, :title => "Chunk 2", :behaviors => 'other_buttons' do
      div do
        text "and here is another"
        span "crazy chunk"
      end
    end
  end
  
end

puts overall.to_html

