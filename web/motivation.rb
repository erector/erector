dir = File.dirname(__FILE__)
require "#{dir}/page"
require "#{dir}/sidebar"

class Motivation < Page

  def render_body
    h1 "Why use Erector?"

    div "Briefly..."

    ul do
      li 'Markaby-style DOM builder domain language'
      li do
        text 'Your views are real classes, written in a real language, allowing'
        ul do
            li 'Functional decomposition'
            li 'Inheritance'
            li 'Composition, not partials'
            li 'Well-defined semantics for variables, loops, blocks'
            li 'Dependency injection via constructor params'
        end
      end
      li 'As little magic as possible (e.g. no automagic copying of "assigns" variable from your controller)'
      li 'yield works again (Markaby broke it)'
      li 'Very testable'
      li 'form_for ERB code is craaaaazy (not to mention the quagmire of options vs. htmloptions)'
      li 'Output is streamed, improving performance over string copy'
    end
  end

end

