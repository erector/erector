class Views::TestCaching::Partial < Erector::Widget

  def content
    cache 'partial_key' do
      text DateTime.current
    end
  end

end
