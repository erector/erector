# todo: make more like http://github.com/justinfrench/formtastic

class Form < Erector::Widget
  needs :action, :method => "post"
  
  def content
    form :method => form_method, :action => @action do
      unless rest_method == form_method
        input :type => "hidden", :name => "_method", :value => rest_method
      end
      super
    end
  end
  
  def method
    @method.to_s.downcase
  end
  
  def form_method
    if method == "get"
      "get"
    else
      "post"
    end
  end
  
  def rest_method
    method
  end
end
