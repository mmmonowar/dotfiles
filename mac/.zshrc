# shellcheck shell=bash
# This .zshrc is for mac
# 1. PATH & ENVIRONMENT
# -----------------------------------------------------------------------------
# Determine the root of the dotfiles repository dynamically
# shellcheck disable=SC2296,SC2298,SC2299
export DOTFILES_ROOT="${${${(%):-%x}:A}:h:h}"
export OS_ENV="mac"

# Load UX Settings
if [[ -f "$DOTFILES_ROOT/common/.polyterm_settings" ]]; then
    source "$DOTFILES_ROOT/common/.polyterm_settings"
fi

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

# shellcheck disable=SC1091
source $(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

alias kbcheck='hidutil property --get "UserKeyMapping"'
alias fixkb='~/kb_toggle.sh'

function dot-sync() {
    local DOT_PATH="$DOTFILES_ROOT"
    local current_dir=$(pwd)

    if [ -d "$DOT_PATH" ]; then
        cd "$DOT_PATH"

        if [[ "$POLYTERM_SCAN_ON_PUSH" == "true" ]]; then
            echo "󰒃  Running pre-sync security check..."
            dot-scan
        fi

        echo "󰋼  Checking dependencies..."
        local BREW_CORE="$DOT_PATH/mac/Brewfile.core"
        local BREW_APPS="$DOT_PATH/mac/Brewfile.apps"

        # Self-healing: Ensure dependencies are installed/updated
        if ! brew bundle check --file="$BREW_CORE" &>/dev/null || ! brew bundle check --file="$BREW_APPS" &>/dev/null; then
            echo "🩹  Healing: Installing missing or outdated dependencies..."
            brew bundle --file="$BREW_CORE"
            brew bundle --file="$BREW_APPS"
        fi

        echo "󰇊  Updating Brewfile..."
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

        # Sync hledger journal if the destination repository exists
        if [[ -f "$DOT_PATH/common/hledger-sync.sh" ]]; then
            source "$DOT_PATH/common/hledger-sync.sh"
        fi

        echo "  Syncing configurations to GitHub..."
        git add -A
        git commit -m "Sync: $(date +'%Y-%m-%d %H:%M') [$(hostname)]"
        if git push origin main; then
            echo "󰄬  Dotfiles and Brewfile pushed to GitHub."
        else
            echo "󰅙  Failed to push to GitHub. Check your connection or git status."
        fi

        cd "$current_dir"
    else
        echo "󰅙  Error: Dotfiles directory not found at $DOT_PATH"
    fi
}

function dot-pull() {
    local DOT_PATH="$DOTFILES_ROOT"
    local current_dir=$(pwd)

    if [ -d "$DOT_PATH" ]; then
        cd "$DOT_PATH"
        echo "󰇚  Fetching updates from GitHub..."
        if git pull --verbose origin main; then
            echo "󰏔  Installing any new dependencies from Brewfile..."
            brew bundle --verbose --file="$DOT_PATH/mac/Brewfile.core"
            brew bundle --verbose --file="$DOT_PATH/mac/Brewfile.apps"
            
            if [[ "$POLYTERM_SCAN_ON_PULL" == "true" ]]; then
                echo "󰒃  Running post-pull security scan..."
                dot-scan
            fi

            # Reload configs automatically
            dot-reload
        fi
        cd "$current_dir"
    else
        echo "󰅙  Error: Dotfiles directory not found at $DOT_PATH"
    fi
}

function dot-reload() {
    echo "  Reloading configurations..."
    if [ -f "$HOME/.zshrc" ]; then
        source "$HOME/.zshrc"
    else
        # If ~/.zshrc doesn't exist, source the current file directly
        # shellcheck disable=SC2296
        source "${(%):-%x}"
    fi
    
    # Reload tmux config if the server is running
    if tmux info &>/dev/null; then
        # Update tmux environment to reflect potential repo location changes
        tmux set-environment -g DOTFILES_ROOT "$DOTFILES_ROOT"
        tmux source-file ~/.tmux.conf 2>/dev/null
        echo "󰄬  Tmux configuration reloaded."
    fi
    echo "󰄬  Cockpit reloaded."
}

# Always update security tools on start
(brew upgrade gemini-cli shellcheck lynis &>/dev/null &)

# 8. AI & LLM ALIASES
# -----------------------------------------------------------------------------
if [[ "$(git config user.email 2>/dev/null)" == "developer11.intxk@gmail.com" ]]; then
    # Default to the most cost-effective model
    # 1 million tokens = ~$0.07 (This will make $5 last forever)
    alias gemini="timeout 1h gemini --model flash-lite"

    # Use this for your actual TUI design/logic questions
    # 1 million tokens = ~$0.35
    alias gemini-flash="timeout 1h gemini --model flash-3.0"

    # Only use this when you are totally stuck
    # 1 million tokens = ~$7.00 (This is the only one that could break a $5 budget)
    alias gemini-pro="timeout 1h gemini --model pro-3.1"

    # Simple alias to check if you're over-pacing for your $4.50 cap
    alias check-spend="gcloud beta billing quotas list --format='table(limit,usage)'"

    # Simple safety wrapper for large files
    ask_gemini() {
        if [[ -f "$1" ]]; then
            local file_size=$(stat -f%z "$1")
            if (( file_size > 50000 )); then
                echo "󰒃  Safety: File is too large ($file_size bytes). Use grep or tail first."
                return 1
            fi
        fi
        gemini "$@"
    }
fi

# 9. LOCAL OVERRIDES (Not synced via Git)
# -----------------------------------------------------------------------------
if [[ -f "$HOME/.zshrc_local" ]]; then
    # shellcheck disable=SC1090
    source "$HOME/.zshrc_local"
fi
