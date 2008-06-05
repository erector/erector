# This is an example of how, when using the #widget method, you
# can define methods to have different meanings based on what
# they are nested inside of.

# One thing motivating this example is to make it possible to 
# have custom "tags" that look identical to built-in tags.

dir = File.expand_path(File.dirname(__FILE__))
$LOAD_PATH.unshift("#{dir}/../lib")
require 'erector'

class Blocks < Erector::Widget
  def render
    ul do
      super
    end
  end
  
  def item(*args, &block)
    widget ListItem, *args, &block
  end
end

class ListItem < Erector::Widget
  def render
    li do
      super
    end
  end
end

class Chips < Erector::Widget
  def render
    div do
      super
    end
  end
  
  def item(*args, &block)
    widget NestedDiv, *args, &block
  end
end

class NestedDiv < Erector::Widget
  def render
    div do
      super
    end
  end
end

overall = Erector::Widget.new do

  def blocks(*args, &block)
    widget Blocks, *args, &block
  end

  def chips(*args, &block)
    widget Chips, *args, &block
  end

  blocks do
    item do
      text "in blocks/block"
    end
  end
  
  chips do
    item do
      text "in chips/block"
    end
  end
  
#  p do
#    item do
#      text "this one would blow up if we uncommented it"
#    end
#  end
  
end

puts overall.to_s

