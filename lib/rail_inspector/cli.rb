# frozen_string_literal: true

require "thor"

module RailInspector
  class Cli < Thor
    class << self
      def exit_on_failure? = true
    end

    desc "changelogs RAILS_PATH", "Lint CHANGELOG files for common issues"
    def changelogs(rails_path)
      puts "checking #{rails_path}"
    end
  end
end
