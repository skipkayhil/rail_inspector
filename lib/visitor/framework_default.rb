# frozen_string_literal: true

require "syntax_tree"

require_relative "./hash_to_string"

module Visitor
  class FrameworkDefault < SyntaxTree::Visitor
    attr_reader :config_map

    def initialize
      @config_map = {}
      @target_version_block = false
      @current_version = nil
      @current_framework = nil
    end

    visit_method def visit_case(node)
      return unless target_version_case?(node.value)

      @target_version_block = true
      visit_child_nodes(node)
      @target_version_block = false
    end

    visit_method def visit_when(node)
      return unless @target_version_block

      @current_version = node.arguments.parts[0].parts[0].value

      @config_map[@current_version] = {}
      visit_child_nodes(node)

      @current_version = nil
    end

    visit_method def visit_if(node)
      return unless @target_version_block

      @current_framework =
        case node
        in predicate: SyntaxTree::CallNode[message: { value: "respond_to?" }]
          node.predicate.arguments.arguments.parts[0].value.value
        else
          nil
        end

      visit_child_nodes(node)

      @current_framework = nil
    end

    visit_method def visit_assign(node)
      return unless @target_version_block

      assert_framework(node)

      target = SyntaxTree::Formatter.format(nil, node.target)
      value =
        case node.value
        when SyntaxTree::HashLiteral
          HashToString.new.tap { |v| v.visit(node.value) }.to_s
        when SyntaxTree::StringConcat
          nil
        else
          SyntaxTree::Formatter.format(nil, node.value)
        end
      @config_map[@current_version][target] = value
    end

    private

    def target_version_case?(node)
      node in SyntaxTree::CallNode[
        receiver: SyntaxTree::VarRef[
          value: SyntaxTree::Ident[value: "target_version"]
        ]
      ]
    end

    def assert_framework(node)
      framework =
        case node.target.parent
        in { value: SyntaxTree::Const } |
             { value: SyntaxTree::Kw[value: "self"] }
          nil
        in receiver: { value: { value: framework } }
          framework
        in value: { value: framework }
          framework
        end

      return if @current_framework == framework

      raise "Expected #{@current_framework} to match #{framework}"
    end
  end
end
