dir = File.expand_path(File.dirname(__FILE__))
$LOAD_PATH.unshift("#{dir}/../lib")
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
        b "#{@friend}!", :class => :friend_name
      end
    end
  end
end

puts Hello.new("Barack")
