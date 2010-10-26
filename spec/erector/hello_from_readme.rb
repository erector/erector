here = File.expand_path(File.dirname(__FILE__))
$: << "#{here}/../../lib"

require "erector"

class Hello < Erector::Widget
  def content
    html do
      head do
        title "Welcome page"
      end
      body do
        p "Hello, world"
      end
    end
  end
end
puts Hello.new.to_html
