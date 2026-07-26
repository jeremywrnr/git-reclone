# justfile for git-reclone

# Variables
gem_name := "git-reclone"
version := `ruby -r./lib/git_reclone/version.rb -e 'puts GitReclone::VERSION'`

# Run tests with RSpec
spec:
    bundle exec rspec --color --format documentation

# Development mode with file watching
dev:
    filewatcher "**/*.rb" "clear && just spec"

# Format/lint code with RuboCop
lint:
    bundle exec rubocop -A git-reclone.gemspec lib/ bin/

# Build and install the gem
build:
    gem build {{gem_name}}.gemspec
    gem install ./{{gem_name}}-{{version}}.gem

# Clean up gem files
clean:
    @echo "cleaning gems..."
    rm -fv *.gem

# Clean, build, and push gem to RubyGems
push: ci clean build
    gem push {{gem_name}}-{{version}}.gem

# Run tests and show coverage in terminal
cov:
    @COVERAGE=1 bundle exec rspec --color --format progress

# Show HTML test coverage
cov-html: cov
    open coverage/index.html

# Run CI checks
ci: spec cov lint

# List all available recipes
help:
    @just --list
