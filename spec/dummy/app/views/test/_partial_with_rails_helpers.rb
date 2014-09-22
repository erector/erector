class Views::Test::PartialWithRailsHelpers < Erector::Widget
  def content
    form_tag 'foobar' do
      submit_tag
    end
  end
end
