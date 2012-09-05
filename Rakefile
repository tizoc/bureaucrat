require "rubygems"
require "rake/testtask"
require "bundler/setup"
require "bundler/gem_tasks"

task :default => :test

desc 'Run all tests'
Rake::TestTask.new(:test) do |t|
  t.pattern = './test/**/*_test.rb'
  t.verbose = false
end
