begin
  require 'rspec'
rescue LoadError
  require 'rubygems' unless ENV['NO_RUBYGEMS']
  gem 'rspec'
  require 'rspec'
end

IS_RSPEC = true

$:.unshift(File.dirname(__FILE__) + '/../lib')
require 'app-tester'
