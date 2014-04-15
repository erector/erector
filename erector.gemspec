# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'erector/version'

Gem::Specification.new do |spec|
  spec.name = "erector"
  spec.version = Erector::VERSION
  spec.authors = [
    "Alex Chaffee",
    "Brian Takita",
    "Jeff Dean",
    "Jim Kingdon",
    "John Firebaugh",
  ]
  spec.summary = "HTML/XML Builder library"
  spec.email = "erector@googlegroups.com"
  spec.description = "Erector is a Builder-like view framework, inspired by Markaby but overcoming some of its flaws. In Erector all views are objects, not template files, which allows the full power of object-oriented programming (inheritance, modular decomposition, encapsulation) in views."

  spec.homepage = "http://erector.rubyforge.org/" # todo: change to github pages
  spec.license = "MIT"

  spec.files = `git ls-files`.split($/)
  spec.executables = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.extra_rdoc_files = [
    "README.txt",
    "History.txt"
  ]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"

  spec.add_dependency(%q<treetop>, [">= 1.2.3"])
  spec.add_dependency(%q<nokogiri>, [">= 0"])
  spec.add_dependency(%q<jeweler>, [">= 0"])
  spec.add_dependency(%q<haml>, [">= 0"])
  spec.add_dependency(%q<sass>, [">= 0"])
end
