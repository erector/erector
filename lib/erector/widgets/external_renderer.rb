class ExternalRenderer < Erector::Widget
  needs :classes
  needs :included_stylesheets => true, :inline_styles => true, :included_scripts => true, :inline_scripts => true
  
  def content
    included_stylesheets if @included_stylesheets
    inline_styles if @inline_styles
    included_scripts if @included_scripts
    inline_scripts if @inline_scripts
  end
  
  def rendered_externals(type)
    @classes.map do |klass|
      klass.dependencies(type)
    end.flatten.uniq
  end
  
  def included_scripts
    rendered_externals(:js).each do |external|
      script({:type => "text/javascript", :src => external.text}.merge(external.options))
    end
  end
  
  def included_stylesheets
    rendered_externals(:css).each do |external|
      link({:rel => "stylesheet", :href => external.text, :type => "text/css", :media => "all"}.merge(external.options))
    end
  end

  def inline_styles
    rendered_externals(:style).each do |external|
      style({:type => "text/css", 'xml:space' => 'preserve'}.merge(external.options)) do
        rawtext external.text
      end
    end
  end
  
  def inline_scripts
    rendered_externals(:script).each do |external|
      javascript external.options do
        rawtext external.text
      end
    end
    # todo: allow :load or :ready per external script
    rendered_externals(:jquery).each do |external|
      jquery :load, external.text, external.options
    end
  end

end

