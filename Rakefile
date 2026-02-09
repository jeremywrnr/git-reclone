task default: [:spec, :standard]

# Load git-reclone files straight into ruby path
lib = File.expand_path("../lib/", __FILE__)
$:.unshift lib unless $:.include?(lib)

# gem name, version
g = "git-reclone"
require "git-reclone"
v = GitReclone::VERSION

# Testing
#
require "rspec/core/rake_task"
RSpec::Core::RakeTask.new(:spec) do |rake|
  rake.rspec_opts = "--color --format documentation"
  rake.verbose = true
end

# Linting
#
require "standard/rake"

task :dev do
  sh 'filewatcher "**/*.rb" "clear && rake"'
end

# Gem management
#
task :build do
  sh "gem build #{g}.gemspec"
  sh "gem install ./#{g}-#{v}.gem"
end

task :clean do
  sh "rm -fv *.gem"
end

task push: [:clean, :build] do
  sh "gem push #{g}-#{v}.gem"
end
