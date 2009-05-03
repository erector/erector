# See join.rb for the introduction. This is a solution which
# builds up an array (to keep track of which tabs are being
# rendered this time) and then renders the appropriate items
# with separators.

require "#{File.dirname(__FILE__)}/../lib/erector"

class Tabs < Erector::Widget

  # note that we are replacing the default options hash with a
  # normal unnamed parameter list. That means we have to call 
  # super() so the parent gets initialized with no parameters
  def initialize(show_one, show_two)
    @show_one = show_one
    @show_two = show_two
    super()
  end

  def content
    tabs = []
    tabs << :one if @show_one
    tabs << :two if @show_two

    tabs.each_with_index do |tab, index|
      if index != 0
        text nbsp(" |"); text " " # also demonstrating different ways to render whitespace
      end
      
      if tab == :one
        a "One", :href => "/one"
      elsif tab == :two
        a "Two", :href => "/two"
      end
    end
  end

end

puts Tabs.new(false, false).to_s
puts Tabs.new(true, false).to_s
puts Tabs.new(false, true).to_s
puts Tabs.new(true, true).to_s

