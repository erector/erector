describe 'Ruby Prof', performance: true do

  it 'takes time' do
    require 'spec_helper'
    require 'ruby-prof'
    require_relative 'support/basic_widget'

    result = RubyProf.profile do
      Erector.inline {
        div(class: 'foo') {
          p 'Hey!'
        }
      }.to_html
    end

    printer = RubyProf::GraphPrinter.new(result)
    printer.print(STDOUT, sort_method: :self_time)

    printer2 = RubyProf::FlatPrinter.new(result)
    printer2.print(STDOUT, sort_method: :self_time)
  end

end
