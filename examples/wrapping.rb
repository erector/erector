require "#{File.dirname(__FILE__)}/../lib/erector"

x = Erector::Widget.new do
  p "foo"
end

y = Erector::Widget.new do
  div x
end

puts y.to_s

z = Erector::Widget.new do
  div do
    widget x
  end
end

puts z.to_s
