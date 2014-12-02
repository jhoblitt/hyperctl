require "bundler/gem_tasks"
require 'rspec/core/rake_task'
require 'yard'

RSpec::Core::RakeTask.new(:spec)

YARD::Rake::YardocTask.new do |t|
  t.files         = ['lib/**/*.rb']
  t.stats_options = ['--list-undoc']
end

task :default => [
  :spec,
]
