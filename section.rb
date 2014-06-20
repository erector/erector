dir = File.dirname(__FILE__)
require "#{dir}/source"

class Section < Erector::InlineWidget
  include Source # todo: make it not an InlineWidget after all

  needs :name, :href => nil, :sections => []
  attr_reader :name, :sections

  def href
    @href || @name.split(':').first.gsub(/[^\w]/, '').downcase
  end

  # todo: unify with Article
  def <<(section)
    @sections << section
    self
  end
  
  def add(options, &block)
    Section.new(options, &block).tap do |sec|
      self << sec
    end
  end
  
  def sections?
    !@sections.empty?
  end
  
end
