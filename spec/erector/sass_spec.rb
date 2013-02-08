require File.expand_path("#{File.dirname(__FILE__)}/../spec_helper")

module CacheSpec
  describe Erector::Sass do
    include Erector::Mixin
    describe 'the #sass method' do
      it "renders SCSS by default, since that's what Sass recommends these days" do
        erector {sass SAMPLE_SCSS}.should == SAMPLE_CSS
      end
      it "renders SASS with explicit option" do
        erector {sass SAMPLE_SASS, :syntax => :sass}.should == SAMPLE_CSS
      end
      it "renders SCSS with explicit option" do
        erector {sass SAMPLE_SCSS, :syntax => :scss}.should == SAMPLE_CSS
      end
    end

    describe 'the #scss method' do
      it "renders SCSS" do
        erector {scss SAMPLE_SCSS}.should == SAMPLE_CSS
      end
    end
  end
end

SAMPLE_SASS =<<-SASS.strip
h1
  height: 118px
  margin-top: 1em

.tagline
  font-size: 26px
  text-align: right
SASS

SAMPLE_SCSS =<<-CSS.strip
h1 {
  height: 118px;
  margin-top: 1em;
}

.tagline {
  font-size: 26px;
  text-align: right;
}
CSS

SAMPLE_CSS =<<-CSS.strip
<style>h1 {
  height: 118px;
  margin-top: 1em; }

.tagline {
  font-size: 26px;
  text-align: right; }
</style>
CSS
