class Section < Erector::Widget
  attr_reader :title

  def initialize(title = 'Section', &block)
    super(&block)
    @title = title
  end

  def href
    title.split(':').first.gsub(/[^\w]/, '').downcase
  end
end
