require File.expand_path("#{File.dirname(__FILE__)}/rails_spec_helper")

describe Erector do

  SETTINGS = {
      :ignore_extra_controller_assigns          => true,
      :controller_assigns_propagate_to_partials => true
  }

  SETTINGS.each { |s, v| test_default(s, v) }

end