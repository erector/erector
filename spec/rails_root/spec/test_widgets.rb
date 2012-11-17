class TestWidget < Erector::Widget
  def content
    text @foobar
  end

  def content_method
    text "content_method"
  end
end

class TestFormWidget < Erector::Widget
  def content
    form_tag('/') do
      h1 "Create a foo"
      rawtext text_field_tag(:name)
    end
  end
end

class NeedsWidget < Erector::Widget
  needs :foo, :bar => true

  def content
    text "foo #{@foo} bar #{@bar}"
  end
end
