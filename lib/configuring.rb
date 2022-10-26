# frozen_string_literal: true

require_relative "./configuring/check/general_configuration"
require_relative "./configuring/check/framework_defaults"

class Configuring
  class CachedParser
    def initialize
      @cache = {}
    end

    def call(path)
      @cache[path] ||= SyntaxTree.parse(SyntaxTree.read(path))
    end
  end

  DOC_PATH = "guides/source/configuring.md"
  APPLICATION_CONFIGURATION_PATH =
    "railties/lib/rails/application/configuration.rb"

  class Doc
    attr_accessor :general_config, :versioned_defaults

    def initialize(content)
      @before, @versioned_defaults, @general_config, @after =
        content
          .split("\n")
          .slice_before do |line|
            [
              "### Versioned Default Values",
              "### Rails General Configuration",
              "### Configuring Assets"
            ].include?(line)
          end
          .to_a
    end

    def to_s
      (@before + @versioned_defaults + @general_config + @after).join("\n") +
        "\n"
    end
  end

  attr_reader :errors, :parser

  def initialize(rails_path)
    @errors = []
    @parser = CachedParser.new
    @rails_path = Pathname.new(rails_path)
  end

  def check
    [Check::GeneralConfiguration, Check::FrameworkDefaults].each do |check|
      check.new(self).check
    end
  end

  def doc
    @doc ||=
      begin
        content = File.read(doc_path)
        Configuring::Doc.new(content)
      end
  end

  def parse(relative_path)
    parser.call(@rails_path.join(relative_path))
  end

  def write!
    File.write(doc_path, doc.to_s)
  end

  private

  def doc_path
    @rails_path.join(DOC_PATH)
  end
end
