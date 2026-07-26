require "spec_helper"

# git-reclone unit testing

describe GitReclone do
  before :each do
    @gn = GitReclone.new(true) # testing
  end

  it "should exit without args" do
    expect(@gn.fire).to eq nil
  end

  it "should show GitReclone help" do
    expect(@gn.parse_opt("--help")).to eq GitReclone::HELP
    expect(@gn.parse_opt("-h")).to eq GitReclone::HELP
  end

  it "should show GitReclone version" do
    expect(@gn.parse_opt("--version")).to eq GitReclone::VERSION
    expect(@gn.parse_opt("-v")).to eq GitReclone::VERSION
  end

  it "should find the correct remote" do
    expect(@gn.remote(%(bitbucket))).to eq "git@bitbucket.org:user/repo.git"
    expect(@gn.remote(%(github))).to eq "https://github.com/user/repo.git"
    expect(@gn.remote(%(gitea))).to eq "https://gitea.example.com/user/repo.git"
    expect(@gn.remote(%(gogs))).to eq "https://gogs.example.com/user/repo.git"
  end

  it "should show all remotes after finding no match" do
    no_remote_err = "No remotes found that match \e[31mfake\e[0m. All remotes:\n" + @gn.remotes.join("\n")
    expect(@gn.remote("fake")).to eq no_remote_err
  end

  it "should disable verification with --force / -f" do
    expect(@gn.instance_variable_get(:@verify)).to eq false
    @gn.instance_variable_set(:@verify, true)
    @gn.parse_opt("--force")
    expect(@gn.instance_variable_get(:@verify)).to eq false

    @gn.instance_variable_set(:@verify, true)
    @gn.parse_opt("-f")
    expect(@gn.instance_variable_get(:@verify)).to eq false
  end

  it "should expose the real (non-mocked) git remotes" do
    expect(@gn.send(:real_remotes)).to be_an(Array)
  end

  it "should support the real (non-mocked) slowp implementation" do
    expect { @gn.send(:real_slowp, "x") }.not_to raise_error
  end

  it "should abort before recloning when confirmation is declined" do
    @gn.instance_variable_set(:@verify, true)
    allow($stdin).to receive(:gets).and_return("n\n")
    expect(@gn.verify(@gn.remotes.first)).to be_nil
  end

  it "should handle pathnames with spaces" do
    remote = "https://github.com/octocat/Hello-World.git"
    gn_test_dir = "../test dir " + Time.now.to_s
    begin
      expect(@gn.reclone(remote, gn_test_dir)).to eq "\e[32mRecloned successfully.\e[0m"
    ensure
      FileUtils.rm_rf(gn_test_dir)
    end
  end

  it "should return nil when cloning from an invalid remote" do
    invalid_remote = "https://github.com/invalid/nonexistent-repo-12345.git"
    gn_test_dir = "../test invalid " + Time.now.to_s
    begin
      expect(@gn.reclone(invalid_remote, gn_test_dir)).to be_nil
    ensure
      FileUtils.rm_rf(gn_test_dir)
    end
  end

  it "should clean up temp directories after successful clone" do
    remote = "https://github.com/octocat/Hello-World.git"
    gn_test_dir = "../test cleanup " + Time.now.to_s
    begin
      before_temps = Dir.glob("/tmp/git-reclone-*")
      @gn.reclone remote, gn_test_dir
      after_temps = Dir.glob("/tmp/git-reclone-*")
      expect(after_temps.length).to eq before_temps.length
    ensure
      FileUtils.rm_rf(gn_test_dir)
    end
  end

  it "should clean up temp directories after failed clone" do
    invalid_remote = "https://github.com/invalid/nonexistent-repo-99999.git"
    gn_test_dir = "../test cleanup fail " + Time.now.to_s
    begin
      before_temps = Dir.glob("/tmp/git-reclone-*")
      @gn.reclone invalid_remote, gn_test_dir
      after_temps = Dir.glob("/tmp/git-reclone-*")
      expect(after_temps.length).to eq before_temps.length
    ensure
      FileUtils.rm_rf(gn_test_dir)
    end
  end

  it "should accept branch parameter for restoration" do
    remote = "https://github.com/octocat/Hello-World.git"
    gn_test_dir = "../test branch " + Time.now.to_s
    begin
      expect(@gn.reclone(remote, gn_test_dir, "main")).to eq "\e[32mRecloned successfully.\e[0m"
    ensure
      FileUtils.rm_rf(gn_test_dir)
    end
  end

  it "should replace the local directory contents when not in testing mode" do
    remote = "https://github.com/octocat/Hello-World.git"
    work_dir = Dir.mktmpdir("git-reclone-real-run-")
    sentinel = File.join(work_dir, "sentinel.txt")
    FileUtils.touch(sentinel)

    begin
      # run inside work_dir so reclone's "replace everything in the
      # current directory" step only ever touches this scratch dir
      Dir.chdir(work_dir) do
        GitReclone.new(false).reclone(remote, work_dir, "main")
      end

      expect(File.exist?(sentinel)).to eq false
      expect(Dir.exist?(File.join(work_dir, ".git"))).to eq true
    ensure
      FileUtils.rm_rf(work_dir)
    end
  end
end
