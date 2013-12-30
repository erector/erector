module ApplicationHelper

  def user_role_unsafe
    'admin'
  end

  def user_role_safe
  	'admin'.html_safe
  end
  

end
