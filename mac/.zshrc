# This .zshrc is for mac
export PATH="/opt/homebrew/bin:$PATH"

# Optimization: Speed up Homebrew by disabling automatic cleanup after install
export HOMEBREW_NO_INSTALL_CLEANUP=1

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
export COLORTERM=truecolor
export MICRO_TRUECOLOR=1

# Define colors for different file types (Mac/BSD format)
export LSCOLORS=Gxfxcxdxbxegedabagacad

# Enable auto-completion coloring
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"

source $(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

alias kbcheck='hidutil property --get "UserKeyMapping"'
alias fixkb='~/kb_toggle.sh'

function dot-sync() {
    local DOT_PATH="$HOME/dotfiles"
    local current_dir=$(pwd)

    if [ -d "$DOT_PATH" ]; then
        cd "$DOT_PATH"
        
        echo "🍺 Updating Brewfile..."
        brew bundle dump --verbose --force --file="$DOT_PATH/mac/Brewfile"

        echo "🔄 Syncing configurations to GitHub..."
        git add -A
        git commit -m "Sync: $(date +'%Y-%m-%d %H:%M') [$(hostname)]"
        if git push origin main; then
            echo "✅ Dotfiles and Brewfile pushed to GitHub."
        else
            echo "❌ Failed to push to GitHub. Check your connection or git status."
        fi
        
        cd "$current_dir"
    else
        echo "❌ Error: Dotfiles directory not found at $DOT_PATH"
    fi
}

function dot-pull() {
    local DOT_PATH="$HOME/dotfiles"
    local current_dir=$(pwd)

    if [ -d "$DOT_PATH" ]; then
        cd "$DOT_PATH"
        echo "📡 Fetching updates from GitHub..."
        if git pull origin main; then
            echo "📦 Installing any new dependencies from Brewfile..."
            brew bundle --verbose --file="$DOT_PATH/mac/Brewfile"
            
            # Reload configs automatically
            source ~/.zshrc
            tmux source-file ~/.tmux.conf 2>/dev/null
            echo "✅ Cockpit updated and reloaded."
        fi
        cd "$current_dir"
    else
        echo "❌ Error: Dotfiles directory not found at $DOT_PATH"
    fi
}

function dot-reload() {
    echo "🔄 Reloading configurations..."
    source ~/.zshrc
    tmux source-file ~/.tmux.conf 2>/dev/null
    echo "✅ Cockpit reloaded."
}
