dir = File.dirname(__FILE__)
if (
  ActionController::Base.instance_methods + ActionController::Base.private_instance_methods).
  include?("add_variables_to_assigns")
  require File.expand_path("#{dir}/action_controller/1.2.5/action_controller")
else
  require File.expand_path("#{dir}/action_controller/2.2.0/action_controller")
end
