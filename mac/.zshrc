# This .zshrc is for mac
export PATH="/opt/homebrew/bin:$PATH"

# Auto-start tmux on shell login (optional)
if [[ -z "$TMUX" ]]; then
    tmux attach-session -t default || tmux new-session -s default
fi

[ ! -f "$HOME/.x-cmd.root/X" ] || . "$HOME/.x-cmd.root/X" # boot up x-cmd.

# Add this to your ~/.zshrc or ~/.bashrc
alias search='ddgr --reg en-us --num 5'

# Reload the tmux config for the current session
alias reload-tmux='tmux source-file ~/.tmux.conf && echo "Tmux reloaded."'

# Kill the server (effectively your restart)
alias restart-tmux='tmux kill-server'

# Enable colorized output for ls
export CLICOLOR=1

# Define colors for different file types (Mac/BSD format)
export LSCOLORS=Gxfxcxdxbxegedabagacad

# Enable auto-completion coloring
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"

source $(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

alias kbcheck='hidutil property --get "UserKeyMapping"'
alias fixkb='~/kb_toggle.sh'

function dot-pull() {
    local current_dir=$(pwd)
    cd ~/dotfiles
    echo "📡 Fetching updates from GitHub..."
    git pull origin main
    
    # Reload configs automatically
    source ~/.zshrc
    tmux source-file ~/.tmux.conf 2>/dev/null
    
    cd $current_dir
    echo "✅ Cockpit updated and reloaded."
}
