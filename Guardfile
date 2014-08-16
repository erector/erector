group :main do
  guard :rspec,
        all_on_start: false,
        all_after_pass: false,
        spec_paths: ['spec/dummy', 'spec/erector'],
        cmd: 'rspec'  do

    watch(%r{^spec/.+_spec\.rb$})
    watch(%r{^lib/(.+)\.rb$})             { |m| "spec/#{m[1]}_spec.rb" }

  end
end

group :perf do
  guard :rspec,
        all_on_start: false,
        all_after_pass: false,
        spec_paths: ['spec/performance'],
        cmd: 'rspec'  do

  end
end
