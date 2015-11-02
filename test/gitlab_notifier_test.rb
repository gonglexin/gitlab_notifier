require 'test_helper'

class GitlabNotifierTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::GitlabNotifier::VERSION
  end
end
