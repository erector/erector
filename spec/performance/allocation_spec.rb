require 'spec_helper'
require 'allocation_stats'
require_relative 'support/basic_widget'

describe 'Allocation', performance: true do

  it 'takes time' do
    stats = AllocationStats.trace do
      Erector.inline {
        div(class: 'foo') {
          p 'Hey!'
        }
      }.to_html
    end

    puts stats.allocations(alias_paths: true).group_by(:sourcefile, :sourceline, :class).to_text
  end

end
