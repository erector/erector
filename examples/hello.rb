require "#{File.dirname(__FILE__)}/../lib/erector"

class Hello < Erector::Widget
  def content
    instruct
    html do
      head do
        title "Hello"
      end
      body do
        text "Hello, "
        b "#{friend}!", :class => :friend_name
      end
    end
  end
end

puts Hello.new(:friend => "Barack")
