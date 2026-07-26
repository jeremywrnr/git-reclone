# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift lib unless $LOAD_PATH.include?(lib)

require 'git_reclone/version'

Gem::Specification.new do |g|
  g.author = 'Jeremy Warner'
  g.email = 'jeremy.warner@berkeley.edu'

  g.name = 'git-reclone'
  g.version = GitReclone::VERSION
  g.platform = Gem::Platform::RUBY
  g.summary = 'Replace your local git repo with a fresh clone from the remote'
  g.description = 'A tool to safely replace your local git repository with a fresh clone from the remote. Clones to a temporary directory first to protect your local copy if something goes wrong, and automatically restores your current branch.'
  g.homepage = 'http://github.com/jeremywrnr/git-reclone'
  g.license = 'MIT'
  g.required_ruby_version = '>= 3.1'

  g.add_dependency 'colored', '>= 1.2', '~> 1.2'
  g.add_development_dependency 'rspec', '~> 3.0'
  g.add_development_dependency 'simplecov', '~> 0.22.0'

  g.files = Dir.glob('{bin,lib}/**/*') + %w[readme.md CHANGELOG.md]
  g.executables = Dir.glob('bin/*').map(&File.method(:basename))
  g.require_path = 'lib'
end
