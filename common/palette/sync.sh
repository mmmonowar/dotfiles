#!/bin/zsh

# ==========================================
# 🔄  SYNCHRONIZATION & AUTOMATION FUNCTIONS
#  ==========================================

function palette() {
    source "$DOTFILES_ROOT/common/palette/palette.sh"
}

function dot-sync() {
    local DOT_PATH="$DOTFILES_ROOT"
    local current_dir=$(pwd)
    local device_id
    device_id=$(hostname | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9_-]//g')

    if [ -d "$DOT_PATH" ]; then
        cd "$DOT_PATH"

        if [[ "$POLYTERM_SCAN_ON_PUSH" == "true" ]]; then
            echo "󰒃  Running pre-sync security check..."
            dot-scan
        fi

        echo "󰋼  Checking dependencies..."
        local brew_core_path="$DOT_PATH/OS/$OS_ENV/Brewfile.core"
        if [[ -f "$DOT_PATH/OS/$OS_ENV/$device_id/Brewfile.core" ]]; then
            brew_core_path="$DOT_PATH/OS/$OS_ENV/$device_id/Brewfile.core"
        fi

        local brew_apps_path="$DOT_PATH/OS/$OS_ENV/Brewfile.apps"
        if [[ -f "$DOT_PATH/OS/$OS_ENV/$device_id/Brewfile.apps" ]]; then
            brew_apps_path="$DOT_PATH/OS/$OS_ENV/$device_id/Brewfile.apps"
        elif [[ -d "$DOT_PATH/OS/$OS_ENV/$device_id" ]]; then
            brew_apps_path="$DOT_PATH/OS/$OS_ENV/$device_id/Brewfile.apps"
        fi

        # Self-healing: Ensure dependencies are installed/updated
        if ! brew bundle check --file="$brew_core_path" &>/dev/null || ! brew bundle check --file="$brew_apps_path" &>/dev/null; then
            echo "🩹  Healing: Installing missing or outdated dependencies..."
            brew bundle --file="$brew_core_path"
            brew bundle --file="$brew_apps_path"
        fi

        echo "󰇊  Updating Brewfile..."
        local TEMP_BREW=$(mktemp)
        brew bundle dump --force --file="$TEMP_BREW"

        # Update Brewfile.apps (all items NOT in Brewfile.core)
        grep -E '^(brew|cask|vscode)' "$TEMP_BREW" | while read -r line; do
            app_name=$(echo "$line" | sed -E 's/^(brew|cask|vscode) "([^"]+)".*/\2/')
            if ! grep -q "\"$app_name\"" "$brew_core_path"; then
                echo "$line"
            fi
        done > "$brew_apps_path"
        rm "$TEMP_BREW"

        # Sync hledger journal if the sync script exists
        if [[ -f "$DOT_PATH/common/palette/hledger-sync.sh" ]]; then
            source "$DOT_PATH/common/palette/hledger-sync.sh"
        fi

        # Dynamically collect and update device list
        if [[ -f "$DOT_PATH/common/palette/update_device.py" ]]; then
            python3 "$DOT_PATH/common/palette/update_device.py" "$DOT_PATH"
        fi

        echo "  Syncing configurations to GitHub..."
        git add -A
        # Commit message uses YYYY-MM-DD-hh-mm-ss as required by project memory rules
        local timestamp
        timestamp=$(date +'%Y-%m-%d-%H-%M-%S')
        git commit -m "Sync: ${timestamp} [$(hostname)]"
        
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
    local device_id
    device_id=$(hostname | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9_-]//g')

    if [ -d "$DOT_PATH" ]; then
        cd "$DOT_PATH"
        echo "󰇚  Fetching updates from GitHub..."
        if git pull --verbose origin main; then
            echo "󰏔  Installing any new dependencies from Brewfile..."
            
            local brew_core_path="$DOT_PATH/OS/$OS_ENV/Brewfile.core"
            if [[ -f "$DOT_PATH/OS/$OS_ENV/$device_id/Brewfile.core" ]]; then
                brew_core_path="$DOT_PATH/OS/$OS_ENV/$device_id/Brewfile.core"
            fi

            local brew_apps_path="$DOT_PATH/OS/$OS_ENV/Brewfile.apps"
            if [[ -f "$DOT_PATH/OS/$OS_ENV/$device_id/Brewfile.apps" ]]; then
                brew_apps_path="$DOT_PATH/OS/$OS_ENV/$device_id/Brewfile.apps"
            fi

            brew bundle --verbose --file="$brew_core_path"
            brew bundle --verbose --file="$brew_apps_path"
            
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
        # Fallback
        source "$DOTFILES_ROOT/OS/$OS_ENV/zshrc" 2>/dev/null || source "$DOTFILES_ROOT/OS/$OS_ENV/.zshrc" 2>/dev/null
    fi
    
    # Reload tmux config if the server is running
    if tmux info &>/dev/null; then
        tmux set-environment -g DOTFILES_ROOT "$DOTFILES_ROOT"
        tmux source-file ~/.tmux.conf 2>/dev/null
        echo "󰄬  Tmux configuration reloaded."
    fi
    echo "󰄬  Cockpit reloaded."
}
