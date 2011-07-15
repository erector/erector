$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)

require "rubygems"
require "bundler"
Bundler.setup

require "erector"
require "nokogiri"
require "rr"
require 'tempfile'
require 'ostruct'
require "rspec"
require "rspec/autorun"
require "open3"

unless '1.9'.respond_to?(:force_encoding)
  String.class_eval do
    begin
      remove_method :chars
    rescue NameError
      # OK
    end
  end
end

module Matchers
  # borrowed from http://github.com/aiwilliams/spec_goodies

  class IncludeOnly # :nodoc:all
    def initialize(*expected)
      @expected = expected.flatten
    end

    def matches?(actual)
      @missing = @expected.reject {|e| actual.include?(e)}
      @extra = actual.reject {|e| @expected.include?(e)}
      @extra.empty? && @missing.empty?
    end

    def failure_message
      message = "expected to include only #{@expected.inspect}"
      message << "\nextra: #{@extra.inspect}" unless @extra.empty?
      message << "\nmissing: #{@missing.inspect}" unless @missing.empty?
      message
    end

    def negative_failure_message
      "expected to include more than #{@expected.inspect}"
    end

    def to_s
      "include only #{@expected.inspect}"
    end
  end

  # Unlike checking that two Enumerables are equal, where the
  # objects in corresponding positions must be equal, this will
  # allow you to ensure that an Enumerable has all the objects
  # you expect, in any order; no more, no less.
  def include_only(*expected)
    IncludeOnly.new(*expected)
  end
end

RSpec.configure do |config|
  include Matchers
  config.mock_with :rr
end

def capturing_output
  output = StringIO.new
  $stdout = output
  yield
  output.string
ensure
  $stdout = STDOUT
end

def capturing_stderr
  output = StringIO.new
  $stderr = output
  yield
  output.string
ensure
  $stderr = STDERR
end

def sys(cmd, expected_status = 0)
  start_time = Time.now
  $stderr.print cmd
  Open3.popen3(cmd) do |stdin, stdout, stderr, wait_thread|
    # in Ruby 1.8, wait_thread is nil :-( so just pretend the process was successful (status 0)
    exit_status = (wait_thread.value.exitstatus if wait_thread) || 0
    output = stdout.read # + stderr.read #todo: make stderr optional
    unless expected_status.nil?
      unless exit_status == expected_status
        $stderr.puts " => #{exit_status}"
        puts output
        exit_status.should == expected_status
      end
#      assert { output and exit_status == expected_status }
    end
    yield output if block_given?
    output
  end
ensure
  $stderr.puts " (#{"%.2f" % (Time.now - start_time)} sec)"
end

def clear_bundler_env
  # Bundler inherits its environment by default, so clear it here
  %w{BUNDLE_PATH BUNDLE_BIN_PATH BUNDLE_GEMFILE}.each { |var| ENV.delete(var) }
end

