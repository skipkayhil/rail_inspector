# frozen_string_literal: true

require "changelog"
require "test/test_helpers/changelog_fixtures"

class TestChangelog < Minitest::Test
  include ChangelogFixtures

  def test_parses_changelog_file
    railties_changelog = changelog_fixture("railties_06e9fbd.md").read

    entries = Changelog::Parser.new(railties_changelog).parse

    assert_equal 21, entries.length
  end

  def test_entries_without_author_are_invalid
    active_support_changelog = changelog_fixture("active_support_2cf8f37.md").read

    invalid_entries = Changelog::Parser.new(active_support_changelog).parse.reject(&:valid?)

    assert_equal 2, invalid_entries.length
  end
end
