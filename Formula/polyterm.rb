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
    # Uses SSH URL — requires SSH key configured for GitHub on the user's machine.
    system "git", "clone", "--depth=1", "-b", "main",
           "git@github.com:mmmonowar/dotfiles.git", Dir.pwd
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
