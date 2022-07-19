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
      @sections = []

      @entries = []
    end

    def parse
      until @buffer.eos?
        next parse_footer if peek_footer?
        pop_entry if @buffer.peek(1) == "*"
        parse_section
      end

      entries
    end

    private

    def parse_section
      @sections << @buffer.scan_until(/\n{2,}/)
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

    # def skip_whitespace
    #   @buffer.skip(/\s+/)
    # end

    def pop_entry
      header = @sections.shift if @sections.first&.start_with?(/^\*/)
      authors = @sections.pop if @sections.last&.match?(
        /^\s+\*[^\d\s]+(\s[^\d\s]+)*\*/
      )
      sections = (@sections.empty? ? nil : @sections.join("\n\n"))

      @entries << Changelog::Entry.new(header, sections, authors)
      @sections.clear
    end
  end
end
