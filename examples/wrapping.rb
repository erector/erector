# This is an example of the ability to pass a widget in
# to contexts which can also take strings, and have the
# rendered output of the widget appear in that location.

# Understanding this simple example may help with more
# complicated examples like the join and block/widget
# examples in this directory.

require "#{File.dirname(__FILE__)}/../lib/erector"

x = Erector.inline do
  p "foo"
end

y = Erector.inline do
  div x
end

puts y.to_html

z = Erector.inline do
  div do
    widget x
  end
end

puts z.to_html
