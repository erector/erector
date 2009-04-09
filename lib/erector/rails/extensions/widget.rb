dir = File.dirname(__FILE__)
require "#{dir}/widget/helpers"

if ActionView::Base.instance_methods.include?("output_buffer")
  require "#{dir}/widget/2.2.0/widget"
else
  require "#{dir}/widget/1.2.5/widget"
end