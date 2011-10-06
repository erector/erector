#!/usr/bin/env bash

project_name=erector

# remove annoying "warning: Insecure world writable dir"
function remove_annoying_warning() {
  chmod go-w $HOME/.rvm/gems/${desired_ruby}{,@{global,${project_name}}}{,/bin} 2>/dev/null
}

# enable rvm for ruby interpreter switching
source $HOME/.rvm/scripts/rvm || exit 1

# show available (installed) rubies (for debugging)
rvm list

for desired_ruby in ruby-1.9.2-p290 ruby-1.8.7-p334; do

  echo ""
  echo "== $desired_ruby"

  # install our chosen ruby if necessary
  rvm list | grep $desired_ruby > /dev/null || rvm install $desired_ruby || exit 1

  # use our ruby with a custom gemset
  rvm use ${desired_ruby}@${project_name} --create
  remove_annoying_warning

  # install bundler if necessary
  gem list --local bundler | grep bundler || gem install bundler || exit 1
  
  # conditionally install project gems from Gemfile
  echo "Checking gems for main project"
  bundle check || bundle install || exit 1

  # do the same for the rails 2 app
  echo "Checking gems for Rails 2"
  (cd spec/rails2/rails_app; BUNDLE_GEMFILE=./Gemfile bundle check || bundle install || exit 1)

  # remove the warning again after we've created all the gem directories
  remove_annoying_warning

  # finally, run rake
  bundle exec rake cruise

done
