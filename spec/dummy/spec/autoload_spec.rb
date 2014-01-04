require File.expand_path("#{File.dirname(__FILE__)}/rails_spec_helper")

describe 'Autoload' do

  it 'works for templates' do
    Views::Test::Bare.new
  end

  it 'works for partials' do
    Views::Test::Erector.new
  end

end