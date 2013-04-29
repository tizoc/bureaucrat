require "rake/testtask"
require 'rspec/core/rake_task'

task :default => [:spec, :test]

desc 'Run all tests'
Rake::TestTask.new(:test) do |t|
  t.pattern = './test/**/*_test.rb'
  t.verbose = false
end

RSpec::Core::RakeTask.new(:spec)
