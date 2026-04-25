# This .zshrc is for mac
# 1. PATH & ENVIRONMENT
# -----------------------------------------------------------------------------
# Determine the root of the dotfiles repository dynamically
export DOTFILES_ROOT="${${${(%):-%x}:A}:h:h}"

export PATH="/opt/homebrew/bin:$PATH"

# Optimization: Speed up Homebrew by disabling automatic cleanup after install
export HOMEBREW_NO_INSTALL_CLEANUP=1

# Auto-start tmux on interactive shell login
if [[ -o interactive ]] && [[ -z "$TMUX" ]]; then
    # Ensure tmux knows about the dotfiles root
    tmux set-environment -g DOTFILES_ROOT "$DOTFILES_ROOT"
    tmux attach-session -t default 2>/dev/null || tmux new-session -s default
fi

[ ! -f "$HOME/.x-cmd.root/X" ] || . "$HOME/.x-cmd.root/X" # boot up x-cmd.

# Add this to your ~/.zshrc or ~/.bashrc
alias search='ddgr --reg en-us --num 5'
alias glow='glow -w 80'

# Reload the tmux config for the current session
alias reload-tmux='dot-reload'

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
    local DOT_PATH="$DOTFILES_ROOT"
    local current_dir=$(pwd)

    if [ -d "$DOT_PATH" ]; then
        cd "$DOT_PATH"
        
        echo "🍺 Updating Brewfile..."
        local BREW_CORE="$DOT_PATH/mac/Brewfile.core"
        local BREW_APPS="$DOT_PATH/mac/Brewfile.apps"
        local TEMP_BREW=$(mktemp)

        # Dump current state to temp
        brew bundle dump --force --file="$TEMP_BREW"

        # 1. Update Brewfile.apps (all items NOT in Brewfile.core)
        grep -E '^(brew|cask|vscode)' "$TEMP_BREW" | while read -r line; do
            app_name=$(echo "$line" | sed -E 's/^(brew|cask|vscode) "([^"]+)".*/\2/')
            if ! grep -q "\"$app_name\"" "$BREW_CORE"; then
                echo "$line"
            fi
        done > "$BREW_APPS"

        rm "$TEMP_BREW"

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
    local DOT_PATH="$DOTFILES_ROOT"
    local current_dir=$(pwd)

    if [ -d "$DOT_PATH" ]; then
        cd "$DOT_PATH"
        echo "📡 Fetching updates from GitHub..."
        if git pull --verbose origin main; then
            echo "📦 Installing any new dependencies from Brewfile..."
            brew bundle --verbose --file="$DOT_PATH/mac/Brewfile.core"
            brew bundle --verbose --file="$DOT_PATH/mac/Brewfile.apps"
            
            echo "🛡️ Running post-pull security scan..."
            dot-scan

            # Reload configs automatically
            dot-reload
        fi
        cd "$current_dir"
    else
        echo "❌ Error: Dotfiles directory not found at $DOT_PATH"
    fi
}

function dot-reload() {
    echo "🔄 Reloading configurations..."
    if [ -f "$HOME/.zshrc" ]; then
        source "$HOME/.zshrc"
    else
        # If ~/.zshrc doesn't exist, source the current file directly
        # This handles cases where symlinks aren't set up yet
        source "${(%):-%x}"
    fi
    
    # Update tmux environment to reflect potential repo location changes
    if [[ -n "$TMUX" ]]; then
        tmux set-environment -g DOTFILES_ROOT "$DOTFILES_ROOT"
        tmux source-file ~/.tmux.conf 2>/dev/null
    fi
    echo "✅ Cockpit reloaded."
}
ILES_ROOT "$DOTFILES_ROOT"
        tmux source-file ~/.tmux.conf 2>/dev/null
    fi
    echo "✅ Cockpit reloaded."
}
