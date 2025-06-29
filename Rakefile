require "bundler/gem_tasks"
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec)

task :default => :spec

# Load the gem's rake tasks when in a Rails environment
if defined?(Rails)
  Dir[File.join(File.dirname(__FILE__), 'lib', 'rails_route_tester', 'rake_tasks', '*.rake')].each { |f| load f }
end

