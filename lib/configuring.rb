# frozen_string_literal: true

class Configuring
  class Doc
    attr_accessor :versioned_defaults

    def initialize(content)
      @before, @versioned_defaults, @after =
        content
          .split("\n")
          .slice_before do |line|
            [
              "### Versioned Default Values",
              "### Rails General Configuration"
            ].include?(line)
          end
          .to_a
    end

    def to_s
      (@before + @versioned_defaults + @after).join("\n") + "\n"
    end
  end
end
