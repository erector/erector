require 'spec_helper'
require_relative 'support/basic_widget'

Benchmark.bmbm do |x|

  x.report('BasicWidget#to_html') do
    BasicWidget.new.to_html
  end

end
