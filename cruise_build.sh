#!/bin/bash

source $HOME/.rvm/scripts/rvm && source .rvmrc

echo USER=$USER && ruby --version && which ruby && which bundle

rvm list

bundle check || bundle install &&
  rake cruise
