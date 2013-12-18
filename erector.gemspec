$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "erector/version"

Gem::Specification.new do |s|

  s.name = "erector"
  s.version = Erector::VERSION

  s.required_ruby_version = Gem::Requirement.new('>= 2.0.0')
  s.authors = ["Alex Chaffee", "Brian Takita", "Jeff Dean", "Jim Kingdon", "John Firebaugh", "Adam Becker"]
  s.summary = "HTML/XML Builder library"
  s.description = "Erector is a Builder-like view framework, inspired by Markaby but overcoming some of its flaws. In Erector all views are objects, not template files, which allows the full power of object-oriented programming (inheritance, modular decomposition, encapsulation) in views."
  s.email = "adam@dobt.co"

  s.files = `git ls-files`.split("\n")
  s.test_files = `git ls-files -- {features,spec}/*`.split("\n")

  s.homepage = "http://github.com/adamjacobbecker/erector"
  s.require_paths = ["lib"]

  s.add_dependency 'rails', '>= 4.0'
  s.add_dependency 'treetop', '>= 1.2.3'

  s.add_development_dependency 'coveralls'
  s.add_development_dependency 'haml'
  s.add_development_dependency 'nokogiri'
  s.add_development_dependency 'rr'
  s.add_development_dependency 'rspec-rails', '2.12.2'
  s.add_development_dependency 'sass'
  s.add_development_dependency 'simple_form'
  s.add_development_dependency 'sqlite3'
  s.add_development_dependency 'wrong', ">=0.5.4"

end
