require "#{File.dirname(__FILE__)}/../lib/erector"

class HotSauce < Erector::Widget
  external :css, "/css/tapatio.css"
  external :css, "/css/salsa_picante.css", :media => "print"
  external :js, "/lib/jquery.js"
  external :js, "/lib/picante.js"

  def content
    p :class => "tapatio" do
      text "esta salsa es muy picante!"
    end
  end
end

class HotPage < Erector::Widgets::Page
  def body_content
    widget HotSauce
  end
end

puts HotPage.new.to_pretty
