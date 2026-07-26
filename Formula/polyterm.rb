class Polyterm < Formula
  desc "Central management tool for the PolyTerm dotfiles environment"
  homepage "https://github.com/mmmonowar/dotfiles"
  url "https://github.com/mmmonowar/dotfiles.git", branch: "main"
  version "1.0.0"

  depends_on "fzf"
  depends_on "tmux"
  depends_on "zsh"

  def stage(*)
    # Bypass Homebrew's GitDownloadStrategy#stage (apply2files bug on WSL)
    # Public repo — HTTPS clone requires no authentication.
    # GIT_CONFIG_* bypasses broken .gitconfig permissions (ISSUE-73).
    system({"GIT_CONFIG_NOSYSTEM" => "1", "GIT_CONFIG_GLOBAL" => "/dev/null"},
           "git", "clone", "--depth=1", "-b", "main",
           "https://github.com/mmmonowar/dotfiles.git", Dir.pwd)
  end

  def install
    bin.install "bin/polyterm"
    prefix.install "application-package", "common", "OS", "docs", "README.md"
  end

  def caveats
    <<~EOS
      PolyTerm has been installed!

      To complete the setup of your environment, run:
        polyterm setup

      This will:
        - Clone dotfiles to ~/polyterm (if not already present)
        - Initialize polyterm-data at ~/polyterm-data for private user state
        - Set up symbolic links and configurations
        - Install packages and register the device

      Note: polyterm-data is a separate private data repository.
      To sync data across machines, push it to a private remote after setup.
    EOS
  end

  test do
    system "#{bin}/polyterm", "help"
  end
end
