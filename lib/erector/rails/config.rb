module Erector

  mattr_accessor :ignore_extra_controller_assigns
  @@ignore_extra_controller_assigns = true

  mattr_accessor :controller_assigns_propagate_to_partials
  @@controller_assigns_propagate_to_partials = true

end