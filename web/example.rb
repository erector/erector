require 'erector'
here = File.expand_path(File.dirname(__FILE__))
require "#{here}/source"
module Example
  def example ruby, html
    div.example {
      table {
        tr {
          td.before {
            source :ruby, ruby
          }
          td.separator {
            span.separator {
              text character(:rightwards_arrow)
            }
          }
          td.after {
            source :html, html
          }
        }
      }
      div.clear
    }
  end
end
