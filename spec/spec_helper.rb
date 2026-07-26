# Start SimpleCov for test coverage (if available and requested)
if ENV["COVERAGE"]
  begin
    require "simplecov"

    # Use explicit ./ to avoid stdlib conflict
    require_relative "spec_coverage"

    SimpleCov.start do
      add_filter "/spec/"
    end

    # SimpleCov's at_exit runs first, then ours
    SimpleCov.at_exit do
      SimpleCov.result.format!
      # Current coverage is ~79%; ratchet this up as tests are added rather
      # than requiring 100% up front
      display_coverage_summary(fail_under: 75.0)
    end
  rescue LoadError => e
    warn "SimpleCov not available: #{e.message}"
  end
end

require "git_reclone"
require "fileutils"

# mock remotes/puts

class GitReclone
  def exit(x)
  end

  def slowp(*x)
  end

  def printf(*x)
  end

  def puts(*x)
    x.first
  end

  def remotes
    %w[
      https://github.com/user/repo.git
      https://gitea.example.com/user/repo.git
      https://gogs.example.com/user/repo.git
      git@bitbucket.org:user/repo.git
    ]
  end
end
