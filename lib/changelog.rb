# frozen_string_literal: true

require "strscan"

class Changelog
  class Entry
    attr_reader :header, :description, :authors, :errors

    def initialize(header, description, authors)
      @header = header
      @description = description
      @authors = authors

      @errors = []

      validate_whitespace
    end

    def valid?
      @authors && @errors.empty?
    end

    def to_s
      entry = +""
      entry << "#{header}\n"
      entry << "#{description.join("\n")}\n"
      entry << "    *Missing Author*\n\n" unless @authors
      entry
    end

    private

    def validate_whitespace
      @description.each do |line|
        next unless line.end_with?(" ", "\t")
        @errors << { line: line, range: line.rstrip.length..line.length }
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

      header = @lines.shift

      authors =
        @lines.reverse.find { |line| line.match?(/\*[^\d\s]+(\s[^\d\s]+)*\*/) }

      @entries << Changelog::Entry.new(header, @lines, authors)
      @lines = []
    end
  end

  attr_reader :path, :entries

  def initialize(path)
    @path = path
    @entries = parser.parse
  end

  def valid?
    invalid_entries.empty?
  end

  def invalid_entries
    @invalid_entries ||= entries.reject(&:valid?)
  end

  private

  def parser
    @parser ||= Parser.new(File.read(path))
  end
end
