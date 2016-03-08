# git-nukes parsing and opening

=begin

say git nuke (-f)
verify the remote to clone from
clean up the local repository
clone the remote, overwriting

=end

require "colored"
require "git-nuke-version"

class GitNuke
  extend GitNuke::Browser

  def run(args)
    arg = args.shift

    case arg
    when nil # open first remote
      Browser.browse remote

    when "--help", "-h"
      puts GitNuke::Help

    when "--version", "-v"
      puts GitNuke::Version

    when "--alias"
      system "git config --global alias.nuke '!git-nuke'"

    when "--unalias"
      system "git config --global --unset alias.nuke"

    else # check against remotes
      Browser.browse remote(arg)
    end
  end

  def no_repo?
    `git status 2>&1`.split("\n").first ==
      "fatal: Not a git repository (or any of the parent directories): .git"
  end

  def remote(search = /.*/)
    if no_repo?
      puts "Not currently in a git repository.".yellow
      exit 1
    end

    remote = remotes.find { |remote| remote.match search }

    if remote.nil?
      puts "No remotes found that match #{search.to_s.red}. All remotes:\n" +
        remotes.join("\n")
      exit 1
    else
      remote
    end
  end

  def remotes
    %x{git remote -v}.split("\n").map { |r| r.split[1] }.uniq
  end
end


# large constant strings

GitNuke::Help = <<-HELP
git-nuke - git repo restoring tool.

`git nuke` re-clones from the first listed remote, removing the local copy.

to restore from a particular remote repository, specify the host:

`git open bit`,
`git open bucket`,
`git open bitbucket`,
  will all clone from a bitbucket remote.

HELP

