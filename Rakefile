# frozen_string_literal: true

require 'bundler/gem_tasks'
require 'rspec/core/rake_task'
require 'rubocop/rake_task'

desc 'Run style checker'
RuboCop::RakeTask.new(:rubocop) do |task|
  task.fail_on_error = true
end

RSpec::Core::RakeTask.new(:spec)

desc "Generate table of contents for README.md"
task :doctoc do
  if `which doctoc`.strip.empty?
    $stdout.puts 'Skipping doctoc generation; install via "npm install -g doctoc"'
  else
    $stdout.puts 'Generating table of contents for README.md'
    `doctoc README.md`
  end
end

task ci: %i[rubocop spec doctoc]

task default: %i[ci]
