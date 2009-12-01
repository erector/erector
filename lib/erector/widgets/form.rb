# todo: make more like http://github.com/justinfrench/formtastic

class Form < Erector::Widget
  needs :action, :method => "post", :onsubmit => nil, :data => nil
  
  def content
    opts = {:method => form_method, :action => @action}
    opts.merge!(:data => @data) if @data
    opts.merge!(:onsubmit => @onsubmit) if @onsubmit
    form opts do
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
