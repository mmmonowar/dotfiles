class Polyterm < Formula
  desc "Central management tool for the PolyTerm dotfiles environment"
  homepage "https://github.com/mmmonowar/dotfiles"
  url "https://github.com/mmmonowar/dotfiles.git", branch: "main"
  version "1.0.0"

  depends_on "fzf"
  depends_on "tmux"
  depends_on "zsh"

  def install
    # Install the bin/polyterm script
    bin.install "bin/polyterm"
    
    # Install the rest of the repository to the prefix so polyterm can find it
    prefix.install Dir["*"]
  end

  def caveats
    <<~EOS
      PolyTerm has been installed!
      
      To complete the setup of your environment, run:
        polyterm setup
        
      This will:
        - Clone dotfiles to ~/dotfiles (if not already present)
        - Initialize dotfiles-data at ~/dotfiles-data for private user state
        - Set up symbolic links and configurations
        - Install packages and register the device
      
      Note: dotfiles-data is a separate private data repository.
      To sync data across machines, push it to a private remote after setup.
    EOS
  end

  test do
    system "#{bin}/polyterm", "help"
  end
end
