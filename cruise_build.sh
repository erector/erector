#!/bin/bash

source $HOME/.rvm/scripts/rvm || exit 1

rvm use 1.8.6 || rvm install 1.8.6 || exit 1
source .rvmrc
rvm list

echo USER=$USER && ruby --version && which ruby && which bundle

bundle check || bundle install &&
  rake cruise
