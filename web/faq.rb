dir = File.dirname(__FILE__)
require "#{dir}/page"
require "#{dir}/sidebar"

class Faq < Page

  def initialize
    super(:page_title => "FAQ")
  end

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
          a "user guide", :href => 'userguide.html'          
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
          a "erector", :href => "userguide.html#erector"
          text " tool. See the "
          a "repository", :href => "http://github.com/pivotal/erector"
          text " (especially the web directory)."
        end
        
        p do
          text "We also have several examples checked in to the repository in the examples directory."
        end
        
        p do
          text "Currently we don't know of any open-source projects built with Erector so we can't show you working source code for a full Erector webapp."
        end
      end,
      
      Section.new("How does Erector stack up against Markaby?") do
        p do
          text "We loved "
          a "Markaby", :href => "http://code.whytheluckystiff.net/markaby/"
          text " when we first saw it, since it transformed the gnarliness of Rails' ERB views into a clean, functional programming lanugage where views are primarily code with ways to emit HTML, rather than HTML with ways to hack in code. However, we soon realized Markaby had two main flaws:"
          ol do
            li "It didn't go quite far enough down the OO road -- Markaby views are still fragments, not classes"
            li "Its use of instance_eval and capture, as well as a view's functional-but-not-quite-an-object nature, led to too much magic and made it very difficult to debug"
          end
        end
        p do
          text "Erector was conceived as a natural evolution of Markaby, but overcoming these two flaws. We think Erector can do pretty much everything Markaby can; if you find a counterexample, please let us know on the "
          a " mailing list", :href => "http://googlegroups.com/group/erector"
          text "."
        end
      end,
      
      Section.new("How does Erector stack up against HAML?") do
        p do
          a "HAML", :href =>"http://haml.hamptoncatlin.com/"
          text " is beautiful. But it suffers from the same design flaw (or, some would say, advantage) as every templating technology: views are not objects, and markup isn't code. But views want to do codey things like loops and variables and modular decomposition and inheritance, and every effort to wedge control logic into markup ends up smelling like a hack. There's always going to be some algorithmic idiom that's awkward in a template language. We figure, why deny it? Code is code. Embrace your true nature! Lick your screen and taste the code!"
        end
      end,
      
      Section.new("How do I use layouts?") do
        p "Rails has a concept of layouts, which are essentially skeletons for a page, which get fleshed out by views. This is a powerful mechanism for rendering web pages; however, the mechanism Rails uses (via content_for and yield) is fundamentally incompatible with Erector's \"just call the content method\" design."
        p do
          text "We recommend a slightly different approach, known officially as the "
          a "Template Method Design Pattern", :href => "http://en.wikipedia.org/wiki/Template_method_pattern"
          text ": define a parent class (e.g. Page) and have your view widgets extend this class rather than directly extending Erector::Widget. The parent class implements content, and calls down to the child class to render sections or acquire information that's specific to that view."
        end
        p do
          text "For an example with source code, see "
          a "the user guide", :href => "userguide.html#layoutinheritance"
          text ". Also see Alex Chaffee's Page base class, at "
          a " this gist snippet", :href=> 'http://gist.github.com/103976'
          text " (which we may soon integrate into Erector proper)."
        end
      end
      
    ])
  end

end
