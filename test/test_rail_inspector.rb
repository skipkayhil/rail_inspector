# frozen_string_literal: true

class TestRailInspector < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::RailInspector::VERSION
  end
end
