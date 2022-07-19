# frozen_string_literal: true

require "strscan"

module Changelog
  class Entry
    attr_reader :header, :description, :authors

    def initialize(header, description, authors)
      @header = header
      @description = description
      @authors = authors
    end

    def valid?
      return false unless @header
      return false unless @authors

      true
    end

    def to_s
      entry = header
      entry += (description + "\n\n") if description
      entry += (authors || "FIXME") + "\n\n"
      entry
    end
  end

  class Parser
    def self.call(file)
      new(file).parse
    end

    def self.to_proc
      method(:call).to_proc
    end

    attr_reader :entries

    def initialize(file)
      @buffer = StringScanner.new(file)
      @entries = []
    end

    def parse
      until @buffer.eos?
        skip_whitespace
        parse_entry_or_footer
      end

      entries
    end

    def parse_entry_or_footer
      peek_footer? ? parse_footer : parse_entry
    end

    def parse_entry
      sections = []

      begin
        sections << @buffer.scan_until(/\n{2,}/)
      end while @buffer.peek(1) != "*" && !peek_footer?

      header = sections.shift if sections.first&.start_with?(/^\*/)
      authors = sections.pop if sections.last&.match?(
        /^\s+\*[\D\S]+(\s[\D\S]+)*\*/
      )
      sections = (sections.empty? ? nil : sections.join("\n\n"))
      @entries << Changelog::Entry.new(header, sections, authors)
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

    def skip_whitespace
      @buffer.skip(/\s+/)
    end
  end
end
