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
    @changelog = changelog_fixture("active_support_9f0b8eb.md")

    assert_equal 2, offenses.length
  end

  def test_parses_with_extra_newlines
    @changelog = changelog_fixture("action_mailbox_83d85b2.md")

    assert_equal 0, entries.length
  end

  def test_entries_with_trailing_whitespace_are_invalid
    @changelog = changelog_fixture("active_record_936a862.md")

    assert_equal 16, offenses.length
  end

  def test_entries_without_four_leading_spaces
    @changelog = changelog_fixture("active_record_238432d.md")

    assert_equal 5, offenses.length
  end

  def test_entries_with_incorrectly_indented_header
    @changelog = changelog_fixture("active_record_51852d2.md")

    assert_equal 1, offenses.length
  end

  private

  def entries
    @changelog.entries
  end

  def offenses
    entries.flat_map(&:offenses)
  end
end
