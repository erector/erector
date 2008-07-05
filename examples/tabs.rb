dir = File.expand_path(File.dirname(__FILE__))
$LOAD_PATH.unshift("#{dir}/../lib")
require 'erector'

class Tabs < Erector::Widget
  attr_accessor :animals, :plants, :bacteria_and_viruses

  def render
    tabs = []
    if (@animals)
      tabs << raw(Erector::Widget.new { a "Animals", :href => "/animals" })
    end
    
    if (@plants)
      tabs << raw(Erector::Widget.new { a "Plants", :href => "/plants" })
    end
    
    if (@bacteria_and_viruses)
      tabs << raw(Erector::Widget.new { a "Bacteria & Viruses", :href => "/bacteria_and_viruses" })
    end

    separator = raw(Erector::Widget.new { text nbsp(" |"); text " " })
    text(raw(tabs.join(separator)))
  end
end

tabs1 = Tabs.new
tabs1.animals = true; tabs1.bacteria_and_viruses = true;
puts tabs1.to_s

tabs2 = Tabs.new
tabs2.plants = true
puts tabs2.to_s

