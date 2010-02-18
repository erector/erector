module Erector::AvPatch
  def with_output_buffer(buf = '')
    super(Erector::Output.new(:output => buf))
  end
end

ActionView::Base.send :include, Erector::AvPatch
