require File.expand_path("#{File.dirname(__FILE__)}/../spec_helper")

if !Object.const_defined?(:Sass)
  puts "Skipping Sass spec... run 'gem install haml' to enable these tests."
else
  module CacheSpec
    describe Erector::Sass do
      include Erector::Mixin
      it "works" do
        erector {sass SAMPLE_SASS}.should == SAMPLE_CSS
      end
    end
  end
end

SAMPLE_SASS =<<-SASS
h1
  height: 118px
  margin-top: 1em

.tagline
  font-size: 26px
  text-align: right
  SASS

SAMPLE_CSS ="""<style>h1 {
  height: 118px;
  margin-top: 1em; }

.tagline {
  font-size: 26px;
  text-align: right; }
</style>"""
