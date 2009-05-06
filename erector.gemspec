# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{erector}
  s.version = "0.6.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Alex Chaffee", "Brian Takita", "Jeff Dean", "Jim Kingdon"]
  s.date = %q{2009-05-06}
  s.default_executable = %q{erector}
  s.description = %q{Html Builder library.}
  s.email = %q{erector@googlegroups.com}
  s.executables = ["erector"]
  s.extra_rdoc_files = ["README.txt"]
  s.files = ["lib/**/*", "README.txt", "VERSION.yml", "bin/erector", ["spec/core_spec_suite.rb", "spec/erector", "spec/erector/indentation_spec.rb", "spec/erector/unicode_builder_spec.rb", "spec/erector/widget_spec.rb", "spec/erector/widgets", "spec/erector/widgets/table_spec.rb", "spec/rails_spec_suite.rb", "spec/spec.opts", "spec/spec_helper.rb", "spec/spec_suite.rb"], "spec/core_spec_suite.rb", "spec/erector", "spec/erector/indentation_spec.rb", "spec/erector/unicode_builder_spec.rb", "spec/erector/widget_spec.rb", "spec/erector/widgets", "spec/erector/widgets/table_spec.rb", "spec/rails_spec_suite.rb", "spec/spec.opts", "spec/spec_helper.rb", "spec/spec_suite.rb"]
  s.has_rdoc = true
  s.homepage = %q{http://erector.rubyforge.org/}
  s.rdoc_options = ["--inline-source", "--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.1}
  s.summary = %q{Html Builder library.}
  s.test_files = ["spec/core_spec_suite.rb", "spec/erector", "spec/erector/indentation_spec.rb", "spec/erector/unicode_builder_spec.rb", "spec/erector/widget_spec.rb", "spec/erector/widgets", "spec/erector/widgets/table_spec.rb", "spec/rails_spec_suite.rb", "spec/spec.opts", "spec/spec_helper.rb", "spec/spec_suite.rb"]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<treetop>, [">= 1.2.3"])
    else
      s.add_dependency(%q<treetop>, [">= 1.2.3"])
    end
  else
    s.add_dependency(%q<treetop>, [">= 1.2.3"])
  end
end
