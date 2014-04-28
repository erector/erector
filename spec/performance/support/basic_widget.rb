class BasicWidget < Erector::Widget
  def content
    rawtext "<!doctype html>"
    html {
      head {
        title 'My Awesome Page'
      }
      body {
        a 'hi', href: 'http://www.foo.com'

        ul {
          li 'foo'
          li 'bar'
        }
      }
    }
  end
end
