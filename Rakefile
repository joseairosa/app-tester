require 'rubygems'
gem 'hoe', '>= 2.1.0'
gem "json", "~> 1.7.5"
gem "faraday", "~> 0.8.4"
require 'hoe'
require 'fileutils'
require './lib/app-tester'

Hoe.plugin :newgem
# Hoe.plugin :website
# Hoe.plugin :cucumberfeatures

# Generate all the Rake tasks
# Run 'rake -T' to see list of generated tasks (from gem root directory)
$hoe = Hoe.spec 'app-tester' do
  self.developer 'Jose P. Airosa', 'me@joseairosa.com'
  #self.post_install_message = 'PostInstall.txt' # TODO remove if post-install message not required
  self.rubyforge_name       = self.name # TODO this is default value
  # self.extra_deps         = [['activesupport','>= 2.0.2']]

end

require 'newgem/tasks'
Dir['tasks/**/*.rake'].each { |t| load t }

# TODO - want other tests/tasks run by default? Add them to the list
# remove_task :default
task :default => [:rspec]
