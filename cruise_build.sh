#!/bin/bash
source $HOME/.rvm/scripts/rvm && source .rvmrc
echo USER=$USER && ruby --version && which ruby && which bundle
bundle check || bundle install &&
  rake cruise
