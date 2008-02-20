$: << "../lib"
require 'erector'

class Hello < Erector::Widget
  def initialize(friend)
    super
    @friend = friend
  end
  
  def render
    instruct
    html do
      head do
        title "Hello"
      end
      body do
        text "Hello, "
        b "#{@friend}!"
      end
    end
  end
end

puts Hello.new("Barack")
