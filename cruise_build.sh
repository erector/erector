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

# # temporary: try to install the sqlite3 dev libraries
# echo `which sqlite3`
# sudo apt-get install libsqlite3-dev

echo "sqlite gem_make.out:"
cat /home/pivotal/.rvm/gems/ruby-1.9.2-p180@erector/gems/sqlite3-1.3.3/ext/sqlite3/gem_make.out


for desired_ruby in ruby-1.9.2-p180 ruby-1.8.7-p334; do

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
  bundle check || bundle install || exit 1

  # force install the sqlite3 gem since the CI box is a weirdo
  gem install sqlite3 --no-rdoc --no-ri -- --with-sqlite3-include=/usr/include

  # do the same for the rails 2 app
  (cd spec/rails2/rails_app; bundle check || bundle install || exit 1)

  # remove the warning again after we've created all the gem directories
  remove_annoying_warning

  # finally, run rake
  bundle exec rake cruise

done
