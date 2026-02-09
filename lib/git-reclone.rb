# git-reclone gem
# jeremy warner

# todo: add an option to automatically add a backup of the local copy
# todo: add all remotes other than the origins, maintain connections
# todo: -b / --backup, and this actually should be the default (maybe)

require "colored"
require "fileutils"
require "tmpdir"
require "git-reclone-version"

class GitReclone
  def initialize(test = false)
    @pdelay = 0.01 # constant for arrow speed
    @testing = test
    @verify = !test
  end

  def fire(args = [])
    opts = args.select { |a| a[0] == "-" }
    opts.each { |o| parse_opt o }
    exit 0 if @testing || opts.first
    parse_arg((args - opts).first)
  end

  def pexit(msg)
    puts msg
    exit 1
  end

  def parse_opt(o)
    case o
    when "--force", "-f"
      @verify = false
    when "--help", "-h"
      puts GitReclone::HELP
    when "--version", "-v"
      puts GitReclone::VERSION
    end
  end

  def parse_arg(a)
    a.nil? ? verify(remote) : verify(remote(a))
  end

  def no_repo?
    `git status 2>&1`.split("\n").first ==
      "fatal: Not a git repository (or any of the parent directories): .git"
  end

  def git_root
    `git rev-parse --show-toplevel`
  end

  def current_branch
    `git rev-parse --abbrev-ref HEAD`.chomp
  end

  def remotes
    `git remote -v`.split("\n").map { |r| r.split[1] }.uniq
  end

  def reclonebanner
    25.times { |x| slowp "\rpreparing| ".red << "~" * x << "#==>".red }
    25.times { |x| slowp "\rpreparing| ".red << " " * x << "~" * (25 - x) << "#==>".yellow }
    printf "\rREADY.".red << " " * 50 << "\n"
  end

  def slowp(x)
    sleep @pdelay
    printf x
  end

  # trying to parse out which remote should be the new source
  def remote(search = /.*/)
    pexit "Not currently in a git repository.".yellow if no_repo?

    r = remotes.find { |gr| gr.match search }

    pexit "No remotes found in this repository.".yellow if remotes.nil?

    if r.nil?
      errmsg = "No remotes found that match #{search.to_s.red}. All remotes:\n" + remotes.join("\n")
      pexit errmsg
      errmsg
    else
      r
    end
  end

  # show remote to user and confirm location (unless using -f)
  def verify(r)
    reclonebanner
    puts "Remote source:\t".red << r
    puts "Local target:\t".red << git_root

    branch = current_branch
    puts "Current branch:\t".red << branch unless branch == "HEAD"

    if @verify
      puts "Warning: this will replace the local copy with a fresh clone from the remote.".yellow
      printf "Continue recloning local repo? [yN] ".yellow
      unless $stdin.gets.chomp.downcase[0] == "y"
        puts "Reclone aborted.".green
        return
      end
    end

    reclone remote, git_root.chomp, branch unless @testing
  end

  # overwrite the local copy of the repository with the remote one
  def reclone(remote, root, branch = nil)
    # create a temporary directory for cloning
    temp_dir = Dir.mktmpdir("git-reclone-")

    begin
      # clone into temp directory (disable credential prompts)
      cloner = "GIT_TERMINAL_PROMPT=0 git clone \"#{remote}\" \"#{temp_dir}\" > /dev/null 2>&1"

      if system(cloner)
        # clone succeeded, now replace the local copy
        if !@testing
          tree = Dir.glob("*", File::FNM_DOTMATCH).select { |d| ![".", ".."].include? d }
          FileUtils.rmtree(tree)

          # move contents from temp to root
          Dir.glob("#{temp_dir}/*", File::FNM_DOTMATCH).each do |item|
            next if File.basename(item) == "." || File.basename(item) == ".."
            FileUtils.mv(item, root)
          end

          # restore original branch if it exists
          if branch && branch != "HEAD"
            Dir.chdir(root) do
              system("git checkout #{branch} > /dev/null 2>&1")
            end
          end
        end

        puts "Recloned successfully.".green
        "Recloned successfully.".green
      else
        # clone failed
        puts "Clone failed.".red
        nil
      end
    ensure
      # always clean up temp directory
      FileUtils.rm_rf(temp_dir) if Dir.exist?(temp_dir)
    end
  end
end

GitReclone::HELP = <<~HELP
  #{"git reclone".red}: a git repo restoring tool
  
  replaces your local copy with a fresh clone from the remote.
  clones to a temp directory first, so your local copy is safe if the clone fails.
  to restore from a particular remote repository, specify the host:

      git reclone github    # reclone using github
      git reclone bitbucket # reclone using bitbucket
      git reclone gitea     # reclone using gitea
      git reclone gogs      # reclone using gogs
HELP
