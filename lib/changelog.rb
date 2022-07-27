# frozen_string_literal: true

require "strscan"

class Changelog
  class Offense
    attr_reader :line, :range, :message

    def initialize(line, range, message)
      @line = line
      @range = range
      @message = message
    end
  end

  class Entry
    attr_reader :lines, :offenses

    def initialize(lines)
      @lines = lines

      @offenses = []

      validate_authors
      validate_leading_whitespace
      validate_trailing_whitespace
    end

    private

    def header
      lines.first
    end

    def validate_authors
      authors = lines.reverse.find { |line| line.match?(/\*[^\d\s]+(\s[^\d\s]+)*\*/) }

      return if authors

      @offenses << Offense.new(
        header, 0..header.length - 1, "CHANGELOG entry is missing authors."
      )
    end

    def validate_leading_whitespace
      unless header.match?(/\* {3}\S/)
        @offenses << Offense.new(header, 0..3, "CHANGELOG header must start with '*' and 3 spaces")
      end

      lines.each_with_index do |line, i|
        next if i == 0
        next if line.empty?
        next if line.start_with?(" " * 4)

        @offenses << Offense.new(line, 0..3, "CHANGELOG line must be indented 4 spaces")
      end
    end

    def validate_trailing_whitespace
      lines.each do |line|
        next unless line.end_with?(" ", "\t")
        @offenses << Offense.new(
          line,
          (line.rstrip.length + 1)..line.length,
          "Trailing whitespace detected."
        )
      end
    end
  end

  class Parser
    def self.call(file)
      new(file).parse
    end

    def self.to_proc
      method(:call).to_proc
    end

    def initialize(file)
      @buffer = StringScanner.new(file)
      @lines = []

      @entries = []
    end

    def parse
      until @buffer.eos?
        if peek_footer?
          pop_entry
          next parse_footer
        end

        pop_entry if @buffer.peek(1) == "*"

        parse_line
      end

      @entries
    end

    private

    def parse_line
      @lines << @buffer.scan_until(/\n/)[0...-1]
    end

    FOOTER_TEXT = "Please check"

    def parse_footer
      @buffer.scan(
        /#{FOOTER_TEXT} \[\d-\d-stable\]\(.*\) for previous changes\.\n/
      )
    end

    def peek_footer?
      @buffer.peek(FOOTER_TEXT.length) == FOOTER_TEXT
    end

    def pop_entry
      # Ensure we don't pop an entry if we only see newlines and the footer
      return unless @lines.any? { |line| line.match?(/\S/) }

      @entries << Changelog::Entry.new(@lines)
      @lines = []
    end
  end

  class Formatter
    def initialize
      @changelog_count = 0
      @offense_count = 0
    end

    def to_proc
      method(:call).to_proc
    end

    def call(changelog)
      @changelog_count += 1

      changelog.offenses.each { |o| process_offense(changelog, o) }
    end

    def finish
      puts "#{@changelog_count} changelogs inspected, #{@offense_count} offense#{"s" unless @offense_count == 1} detected"
    end

    private

    def process_offense(file, offense)
      @offense_count += 1

      puts "#{file.path}: #{offense.message}"
      puts offense.line
      puts ("^" * offense.range.count).rjust(offense.range.end)
    end
  end

  attr_reader :path, :entries

  def initialize(path)
    @path = path
    @entries = parser.parse
  end

  def valid?
    offenses.empty?
  end

  def offenses
    @offenses ||= entries.flat_map(&:offenses)
  end

  private

  def parser
    @parser ||= Parser.new(File.read(path))
  end
end
