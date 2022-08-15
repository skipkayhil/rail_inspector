# frozen_string_literal: true

class Configuring
  class CachedParser
    def initialize
      @cache = {}
    end

    def call(path)
      @cache[path] ||= SyntaxTree.parse(SyntaxTree.read(path))
    end
  end

  class Resolver
    APPLICATION_CONFIGURATION_PATH =
      "railties/lib/rails/application/configuration.rb"
    DOC_PATH = "guides/source/configuring.md"

    def initialize(rails_path)
      @rails_path = Pathname.new(rails_path)
    end

    def call(file)
      relative_path =
        case file
        in :app_config
          APPLICATION_CONFIGURATION_PATH
        in :doc
          DOC_PATH
        end

      @rails_path.join(relative_path)
    end
  end

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

  attr_reader :parser, :resolver

  def initialize(rails_path)
    @parser = CachedParser.new
    @resolver = Resolver.new(rails_path)
  end

  def doc
    @doc ||=
      begin
        content = File.read(resolver.call(:doc))
        Configuring::Doc.new(content)
      end
  end
end
