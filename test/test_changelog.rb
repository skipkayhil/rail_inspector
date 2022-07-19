# frozen_string_literal: true

require "changelog"

class TestChangelog < Minitest::Test
  def test_parses_changelog_file
    railties_changelog = changelog_fixture("railties_06e9fbd.md").read

    entries = Changelog::Parser.new(railties_changelog).parse

    assert_equal 21, entries.length
  end

  private

  def changelog_fixture(name)
    require "pathname"
    path = Pathname.new(File.expand_path("fixtures/#{name}", __dir__))

    raise ArgumentError, "#{name} fixture not found" unless path.exist?

    path
  end
end
