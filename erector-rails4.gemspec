$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "erector/version"

Gem::Specification.new do |s|

  s.name = "erector-rails4"
  s.version = Erector::VERSION

  s.required_ruby_version = Gem::Requirement.new('>= 1.9.3')
  s.authors = ["Alex Chaffee", "Brian Takita", "Jeff Dean", "Jim Kingdon", "John Firebaugh", "Adam Becker"]
  s.summary = "Erector, for Rails 4"
  s.description = "This is a fork of Erector, updated for Rails 4."
  s.email = "adam@dobt.co"
  s.license     = "MIT"

  s.files = `git ls-files`.split("\n")
  s.test_files = `git ls-files -- {features,spec}/*`.split("\n")

  s.homepage = "http://github.com/ajb/erector-rails4"
  s.require_paths = ["lib"]

  s.add_dependency 'activesupport', '>= 3.0.0'
  s.add_dependency 'treetop'

  s.add_development_dependency 'appraisal', '1.0.0'
  s.add_development_dependency 'coveralls', '0.7.0'
  s.add_development_dependency 'haml', '4.0.5'
  s.add_development_dependency 'guard-rspec', '4.3.1'
  s.add_development_dependency 'nokogiri', '1.6.1'
  s.add_development_dependency 'rails', '>= 3.0.0'
  s.add_development_dependency 'rr', '1.1.2'
  s.add_development_dependency 'rspec-rails', '2.14.2'
  s.add_development_dependency 'sass', '3.3.4'
  s.add_development_dependency 'simple_form'
  s.add_development_dependency 'sqlite3', '1.3.9'
  s.add_development_dependency 'wrong', '0.7.1'

  if RUBY_VERSION >= '2.1'
    s.add_development_dependency 'allocation_stats', '0.1.5'
    s.add_development_dependency 'ruby-prof', '0.15.1'
  end

end
