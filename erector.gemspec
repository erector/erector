# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{erector}
  s.version = "0.5.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Alex Chaffee", "Brian Takita", "Jeff Dean", "Jim Kingdon"]
  s.date = %q{2009-04-12}
  s.default_executable = %q{erect}
  s.description = %q{Html Builder library.}
  s.email = %q{erector-devel@rubyforge.org}
  s.executables = ["erect"]
  s.extra_rdoc_files = [
    "README.txt"
  ]
  s.files = [
    "README.txt",
    "VERSION.yml",
    "bin/erect",
    "lib/erector.rb",
    "lib/erector/erect.rb",
    "lib/erector/erected.rb",
    "lib/erector/extensions/object.rb",
    "lib/erector/indenting.rb",
    "lib/erector/rails.rb",
    "lib/erector/rails/extensions/action_controller.rb",
    "lib/erector/rails/extensions/action_controller/1.2.5/action_controller.rb",
    "lib/erector/rails/extensions/action_controller/2.2.0/action_controller.rb",
    "lib/erector/rails/extensions/action_view.rb",
    "lib/erector/rails/extensions/widget.rb",
    "lib/erector/rails/extensions/widget/1.2.5/widget.rb",
    "lib/erector/rails/extensions/widget/2.2.0/widget.rb",
    "lib/erector/rails/extensions/widget/helpers.rb",
    "lib/erector/rails/supported_rails_versions.rb",
    "lib/erector/rails/template_handlers/1.2.5/action_view_template_handler.rb",
    "lib/erector/rails/template_handlers/2.0.0/action_view_template_handler.rb",
    "lib/erector/rails/template_handlers/2.1.0/action_view_template_handler.rb",
    "lib/erector/rails/template_handlers/2.2.0/action_view_template_handler.rb",
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
    "spec/erect/erect_spec.rb",
    "spec/erect/erected_spec.rb",
    "spec/erect/rhtml_parser_spec.rb",
    "spec/erector/indentation_spec.rb",
    "spec/erector/unicode_builder_spec.rb",
    "spec/erector/widget_spec.rb",
    "spec/erector/widgets/table_spec.rb",
    "spec/rails_spec_suite.rb",
    "spec/spec_helper.rb",
    "spec/spec_suite.rb"
  ]
  s.has_rdoc = true
  s.homepage = %q{http://erector.rubyforge.org/}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.1}
  s.summary = %q{Html Builder library.}
  s.test_files = [
    "spec/rails_spec_suite.rb",
    "spec/spec_suite.rb",
    "spec/erector",
    "spec/erector/indentation_spec.rb",
    "spec/erector/unicode_builder_spec.rb",
    "spec/erector/widgets",
    "spec/erector/widgets/table_spec.rb",
    "spec/erector/widget_spec.rb",
    "spec/erect",
    "spec/erect/erected_spec.rb",
    "spec/erect/rhtml_parser_spec.rb",
    "spec/erect/erect_spec.rb",
    "spec/spec_helper.rb",
    "spec/core_spec_suite.rb"
  ]

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
