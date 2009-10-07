require "#{File.dirname(__FILE__)}/../lib/erector"

x = Erector.inline do
  p "foo"
end

y = Erector.inline do
  div x
end

puts y.to_s

z = Erector.inline do
  div do
    widget x
  end
end

puts z.to_s
