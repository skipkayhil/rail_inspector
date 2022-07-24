# frozen_string_literal: true

require "changelog"
require "test/test_helpers/changelog_fixtures"

class TestChangelog < Minitest::Test
  include ChangelogFixtures

  def test_parses_changelog_file
    @changelog = changelog_fixture("railties_06e9fbd.md")

    assert_equal 21, entries.length
  end

  def test_entries_without_author_are_invalid
    @changelog = changelog_fixture("active_support_2cf8f37.md")

    invalid_entries = entries.reject(&:valid?)

    assert_equal 2, invalid_entries.length
  end

  def test_parses_with_extra_newlines
    @changelog = changelog_fixture("action_mailbox_b5a758d.md")

    assert_equal 0, entries.length
  end

  def test_entries_with_trailing_whitespace_are_invalid
    @changelog = changelog_fixture("active_record_6673d8e.md")

    assert_equal 15, entries.flat_map(&:offenses).length
  end

  private

  def entries
    Changelog::Parser.new(@changelog).parse
  end
end
