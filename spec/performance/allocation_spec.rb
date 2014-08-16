require 'spec_helper'
require 'allocation_stats'
require_relative 'support/basic_widget'

stats = AllocationStats.trace do
  Erector.inline {
    div(class: 'foo') {
      p 'Hey!'
    }
  }.to_html
end

puts stats.allocations(alias_paths: true).group_by(:sourcefile, :sourceline, :class).to_text
