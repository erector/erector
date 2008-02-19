$: << "../lib"
require 'erector'

x = Erector::Widget.new do
  p "foo"
end

y = Erector::Widget.new do
  div x
end

puts y.to_s

z = Erector::Widget.new do
  div do
    x.render_to(doc)
  end
end

puts z.to_s

w = Erector::Widget.new do
  div do
    x.render_for(self)
  end
end

puts w.to_s
