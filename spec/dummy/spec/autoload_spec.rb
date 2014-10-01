require 'spec_helper'

describe 'Autoload' do

  it 'works for templates' do
    Views::Test::Bare.new
  end

  it 'works for partials' do
    Views::Test::Erector.new
  end

end
