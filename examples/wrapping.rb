$: << "../lib"
require 'erector'

x = Erector::Widget.new do
  p "foo"
end

y = Erector::Widget.new do
  div raw(x)
end

puts y.to_s
