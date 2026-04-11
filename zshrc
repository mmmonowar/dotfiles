# This .zshrc is for WSL
# Add local binaries to PATH (Standard practice on Ubuntu instead of Homebrew)
export PATH="$HOME/.local/bin:$PATH"

# Auto-start tmux on shell login (optional)
if [[ -z "$TMUX" ]]; then
    tmux attach-session -t default || tmux new-session -s default
fi

[ ! -f "$HOME/.x-cmd.root/X" ] || . "$HOME/.x-cmd.root/X" # boot up x-cmd.

# ddgr web search alias
alias search='ddgr --reg en-us --num 5'

# Reload the tmux config for the current session
alias reload-tmux='tmux source-file ~/.tmux.conf && echo "Tmux reloaded."'

# Kill the server (effectively your restart)
alias restart-tmux='tmux kill-server'

# Enable colorized output for ls (Ubuntu/GNU format)
alias ls='ls --color=auto'
alias grep='grep --color=auto'

# Set up GNU dircolors if available (replaces Mac's LSCOLORS)
if [ -x /usr/bin/dircolors ]; then
    eval "$(dircolors -b)"
fi

# Enable auto-completion coloring
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"

# Source zsh-syntax-highlighting
# Note: You must install it first via: sudo apt install zsh-syntax-highlighting
if [ -f /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]; then
    source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi

# NOTE: 'hidutil' is a macOS-only command. 
# On Ubuntu, use 'xmodmap', 'setxkbmap', or 'evtest' to check keyboard mappings.
# alias kbcheck='hidutil property --get "UserKeyMapping"'

# Keep your custom keyboard script alias
alias fixkb='~/kb_toggle.sh'
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"


# A clean, Mac-like prompt: [folder] >
PROMPT='%F{cyan}[%1d] > %f'

# Enable colors for the 'ls' command
alias ls='ls --color=auto'

# Use the built-in Ubuntu tool to set the color database
if [ -x /usr/bin/dircolors ]; then
    eval "$(dircolors -b)"
fi

function dot-sync() {
    local current_dir=$(pwd)
    cd ~/dotfiles
    git add .
    git commit -m "Update dotfiles: $(date +'%Y-%m-%d %H:%M')"
    git push origin main
    cd $current_dir
    echo "🚀 Dotfiles pushed to GitHub!"
}
