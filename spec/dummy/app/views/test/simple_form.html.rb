class Views::Test::SimpleForm < Erector::Widget
  def content
    simple_form_for :foo do |f|
    end
  end
end
