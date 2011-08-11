# http://shjs.sourceforge.net/doc/documentation.html
module Source
  def self.included into
    into.external :js, "js/sh_lang.min.js"
    into.external :css, "css/sh_style.css"
  end
  
  def source lang, source_code
    sh_lang = "sh_#{lang}"
    pre source_code, :class => sh_lang
  end
end
