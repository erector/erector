dir = File.dirname(__FILE__)
require "#{dir}/page"
require "#{dir}/sidebar"

class Faq < Page

  def render_body
    text article
  end
  
  def article
    Article.new(
    [
      Section.new("What is Erector?") do
        p do
          text "Erector is a Builder-like view framework, inspired by "
          a "Markaby", :href => "http://code.whytheluckystiff.net/markaby/"
          text " but overcoming some of its flaws. In Erector all views are objects, not template files, which allows the full power of object-oriented programming (inheritance, modular decomposition, encapsulation) in views."
        end
      end,
      
      Section.new("Where are the docs?") do
        p do
          text "See the "
          a "rdoc for the Erector::Widget class", :href => "http://erector.rubyforge.org/rdoc/classes/Erector/Widget.html"
          text " to learn how to make your own widgets, and visit the project site at "
          url "http://erector.rubyforge.org"
          text " for more documentation, especially the "
          a "user guide", :href => 'documentation.html'          
          text "."
        end
      end,
      
      Section.new("Why use Erector?") do
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
          li 'As little magic as possible while maintaining Rails compatibility'
          li 'yield works again (Markaby broke it)'
          li 'Very testable'
          li 'form_for ERB code is craaaaazy (not to mention the quagmire of options vs. htmloptions)'
          li 'Output is streamed, improving performance over string copy'
        end
      end,
      
      Section.new("Where are some examples?") do
        p do
          text "This very web site you're reading right now is built with Erector, using the "
          a "erect", :href => "documentation.html#erect"
          text " tool. See the "
          a "svn repository", :href => "http://erector.rubyforge.org/svn/trunk/web/"
          text " for source code."
        end
        
        p do
          text "Currently there are no open-source projects built with Erector so we can't show you working source code for a full Erector webapp."
        end
      end,
      
      Section.new("How do I use layouts?") do
        p "Rails has a concept of layouts, which are essentially skeletons for a page, which get fleshed out by views. This is a powerful mechanism for rendering web pages; however, the mechanism Rails uses (via content_for and yield) is fundamentally incompatible with Erector's \"just call render\" design."
        p do
          text "We recommend a slightly different approach, known officially as the "
          a "Template Method Design Pattern", :href => "http://en.wikipedia.org/wiki/Template_method_pattern"
          text ": define a parent class (e.g. Page) and have your view widgets extend this class rather than directly extending Erector::Widget. The parent class implements render, and calls down to the child class to render sections or acquire information that's specific to that view."
        end
        p do
          text "For an example, see "
          a "the user guide", :href => "documentation.html#layoutinheritance"
        end
      end
      
    ])
  end

end

