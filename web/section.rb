class Section < Erector::Widget
  attr_reader :title

  def initialize(title = 'Section', name = nil, &block)
    super(&block)
    @title = title
    @name = name || title.split(':').first.gsub(/[^\w]/, '').downcase
  end

  def href
    @name
  end
end
