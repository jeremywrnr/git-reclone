require "git-reclone"
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
