# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{erector}
  s.version = "0.6.3"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Alex Chaffee", "Brian Takita", "Jeff Dean", "Jim Kingdon"]
  s.date = %q{2009-05-06}
  s.default_executable = %q{erector}
  s.description = %q{Html Builder library.}
  s.email = %q{erector@googlegroups.com}
  s.executables = ["erector"]
  s.extra_rdoc_files = [
    "README.txt"
  ]
  s.files = [
    "README.txt",
    "VERSION.yml",
    "bin/erector",
    "lib/erector.rb",
    "lib/erector/erect.rb",
    "lib/erector/erected.rb",
    "lib/erector/extensions/object.rb",
    "lib/erector/indenting.rb",
    "lib/erector/rails.rb",
    "lib/erector/rails/extensions/action_controller.rb",
    "lib/erector/rails/extensions/action_view.rb",
    "lib/erector/rails/extensions/rails_widget.rb",
    "lib/erector/rails/extensions/rails_widget/helpers.rb",
    "lib/erector/rails/rails_version.rb",
    "lib/erector/rails/template_handlers/action_view_template_handler.rb",
    "lib/erector/raw_string.rb",
    "lib/erector/rhtml.treetop",
    "lib/erector/unicode.rb",
    "lib/erector/unicode_builder.rb",
    "lib/erector/version.rb",
    "lib/erector/widget.rb",
    "lib/erector/widgets.rb",
    "lib/erector/widgets/table.rb",
    "spec/core_spec_suite.rb",
    "spec/erector/indentation_spec.rb",
    "spec/erector/unicode_builder_spec.rb",
    "spec/erector/widget_spec.rb",
    "spec/erector/widgets/table_spec.rb",
    "spec/rails_spec_suite.rb",
    "spec/spec.opts",
    "spec/spec_helper.rb",
    "spec/spec_suite.rb"
  ]
  s.homepage = %q{http://erector.rubyforge.org/}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.3}
  s.summary = %q{Html Builder library.}
  s.test_files = [
    "spec/core_spec_suite.rb",
    "spec/erector",
    "spec/erector/indentation_spec.rb",
    "spec/erector/unicode_builder_spec.rb",
    "spec/erector/widget_spec.rb",
    "spec/erector/widgets",
    "spec/erector/widgets/table_spec.rb",
    "spec/rails_spec_suite.rb",
    "spec/spec.opts",
    "spec/spec_helper.rb",
    "spec/spec_suite.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<treetop>, [">= 1.2.5"])
    else
      s.add_dependency(%q<treetop>, [">= 1.2.5"])
    end
  else
    s.add_dependency(%q<treetop>, [">= 1.2.5"])
  end
end
