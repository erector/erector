module Erector
  class RailsWidget < Widget
  end
end

dir = File.dirname(__FILE__)
require "#{dir}/rails_widget/helpers"
if ActionView::Base.instance_methods.include?("output_buffer")
  require "#{dir}/rails_widget/2.2.0/rails_widget"
else
  require "#{dir}/rails_widget/1.2.5/rails_widget"
end