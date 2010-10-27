#!/bin/bash

source $HOME/.rvm/scripts/rvm || exit 1

echo "Rubies:"
rvm list
echo "---"
rvm list | grep ruby-1.8.6-p399 || rvm install ruby-1.8.6-p399 || exit 1

source .rvmrc

echo USER=$USER && ruby --version && which ruby && which bundle

bundle check || bundle install &&
  rake cruise
