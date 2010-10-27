#!/bin/bash

desired_ruby=ruby-1.8.6-p399
project_name=erector

# enable rvm for ruby interpreter switching
source $HOME/.rvm/scripts/rvm || exit 1

# show available (installed) rubies (for debugging)
rvm list

# install our chosen ruby if necessary
rvm list | grep $desired_ruby > /dev/null || rvm install $desired_ruby || exit 1

# use our ruby with a custom gemset
rvm use ${desired_ruby}@${project_name} --create

# remove annoying "warning: Insecure world writable dir"
gemdir=$HOME/.rvm/gems/${desired_ruby}@${project_name}
chmod go-w $gemdir $gemdir/bin

# install bundler if necessary
gem list --local bundler | grep bundler || gem install bundler || exit 1

# debugging info
echo USER=$USER && ruby --version && which ruby && which bundle

# conditionally install project gems from Gemfile
bundle check || bundle install || exit 1

# finally, run rake
rake cruise
