describe 'Widget to HTML', performance: true do

  it 'takes time' do
    require 'spec_helper'
    require_relative 'support/basic_widget'

    Benchmark.bmbm do |x|
      x.report('BasicWidget#to_html') do
        100.times do
          BasicWidget.new.to_html
        end
      end
    end
  end

end
