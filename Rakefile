require 'rubygems'
gem "json", "~> 1.7.5"
gem "faraday", "~> 0.8.4"
require 'fileutils'
require './lib/app-tester'

# Generate all the Rake tasks
# Run 'rake -T' to see list of generated tasks (from gem root direct

Dir['tasks/**/*.rake'].each { |t| load t }

# TODO - want other tests/tasks run by default? Add them to the list
task :default => [:rspec]
