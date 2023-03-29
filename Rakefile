require "minitest/test_task"
require "syntax_tree/rake_tasks"

Minitest::TestTask.create

SyntaxTree::Rake::CheckTask.new
SyntaxTree::Rake::WriteTask.new

task default: [:test, "stree:check"]
