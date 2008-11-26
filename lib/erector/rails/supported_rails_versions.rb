module Erector
  module Rails
    SUPPORTED_RAILS_VERSIONS = {
#      "1.2.5" => {'version' => '1.2.5', 'git_tag' => 'v1.2.5'},
      "1.99.0" => {'version' => '1.99.0', 'git_tag' => 'v2.0.0_RC1'},
      "2.0.2" => {'version' => '2.0.2', 'git_tag' => 'v2.0.2'},
      "2.1.0" => {'version' => '2.1.0', 'git_tag' => 'v2.1.0'},
      "2.2.0" => {'version' => '2.2.0', 'git_tag' => 'v2.2.0'},
      "2.2.2" => {'version' => '2.2.2', 'git_tag' => 'v2.2.2'},
#      "edge" => {'version' => 'edge', 'git_tag' => 'master'}, #TODO: Readd edge support
    }
  end
end
