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
    local DATA_PATH="${DOTFILES_DATA:-${DOTFILES_ROOT}/../polyterm-data}"
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
            python3 "$DOT_PATH/common/palette/update_device.py" "$DATA_PATH"
        fi

        echo "  Syncing dotfiles to GitHub..."
        git add -A
        local timestamp
        timestamp=$(date +'%Y-%m-%d-%H-%M-%S')
        git commit -m "Sync: ${timestamp} [$(hostname)]"
        git push origin main && echo "󰄬  Dotfiles pushed to GitHub." || echo "󰅙  Failed to push dotfiles."

        # Sync polyterm-data (private data repo)
        if [[ -d "$DATA_PATH/.git" ]]; then
            echo "󰇊  Syncing polyterm-data to GitHub..."
            cd "$DATA_PATH"
            git add -A
            git commit -m "Sync: ${timestamp} [$(hostname)]" || true
            git push origin main && echo "󰄬  polyterm-data pushed to GitHub." || echo "󰅙  Failed to push polyterm-data."
        fi

        cd "$current_dir"
    else
        echo "󰅙  Error: Dotfiles directory not found at $DOT_PATH"
    fi
}

function dot-pull() {
    local DOT_PATH="$DOTFILES_ROOT"
    local current_dir=$(pwd)
    local DATA_PATH="${DOTFILES_DATA:-${DOTFILES_ROOT}/../polyterm-data}"
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

            # Pull polyterm-data (private data repo)
            if [[ -d "$DATA_PATH/.git" ]]; then
                echo "󰇚  Fetching polyterm-data updates..."
                cd "$DATA_PATH" && git pull origin main && cd "$DOT_PATH"
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
    [[ -f "$HOME/.zshrc" ]] && source "$HOME/.zshrc" 2>/dev/null
    # Re-source sync.sh so function definitions stay current after .zshrc sourcing
    [[ -f "${DOTFILES_ROOT}/common/palette/sync.sh" ]] && source "${DOTFILES_ROOT}/common/palette/sync.sh" 2>/dev/null

    # Reload tmux config if the server is running
    if tmux info &>/dev/null; then
        tmux set-environment -g DOTFILES_ROOT "$DOTFILES_ROOT"
        tmux source-file ~/.tmux.conf 2>/dev/null
        echo "󰄬  Tmux configuration reloaded."
    fi
    echo "󰄬  Cockpit reloaded."
}

function dot-reload-all() {
    clear
    echo -e "\033[1m󰔄  Full Configuration Reload\033[0m"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "This will:"
    echo "  1. Source shell configurations (zshrc, bashrc)"
    echo "  2. Reload PolyTerm environment settings"
    echo "  3. Reload multiplexer configuration"
    echo "  4. Restart the multiplexer (fresh session)"
    echo ""
    if ! confirm_action "Proceed with full reload?"; then
        echo "󰅙  Reload cancelled."
        return 1
    fi

    echo ""
    echo "󰔄  [1/4] Sourcing shell configurations..."
    [[ -f "$HOME/.zshrc" ]] && source "$HOME/.zshrc" 2>/dev/null && echo "  󰄬  .zshrc sourced"

    local saved_ps1="$PS1"
    [[ -f "$HOME/.bashrc" ]] && source "$HOME/.bashrc" 2>/dev/null && echo "  󰄬  .bashrc sourced"
    PS1="$saved_ps1"

    local sync_sh="${DOTFILES_ROOT}/common/palette/sync.sh"
    [[ -f "$sync_sh" ]] && source "$sync_sh" 2>/dev/null

    echo "󰔄  [2/4] Reloading PolyTerm environment..."
    local data_path="${DOTFILES_DATA:-${DOTFILES_ROOT}/../polyterm-data}"
    local settings_file="${data_path}/settings/.polyterm_settings"
    [[ -f "$settings_file" ]] && source "$settings_file" 2>/dev/null && echo "  󰄬  PolyTerm settings reloaded"

    echo "󰔄  [3/4] Reloading multiplexer configuration..."
    local active_mux=""
    [[ -n "$TMUX" ]] && active_mux="tmux"
    [[ -n "$ZELLIJ" ]] && active_mux="zellij"

    if [[ "$active_mux" == "tmux" ]]; then
        if tmux info &>/dev/null 2>&1; then
            tmux set-environment -g DOTFILES_ROOT "${DOTFILES_ROOT}" 2>/dev/null
            tmux source-file "$HOME/.tmux.conf" 2>/dev/null && echo "  󰄬  Tmux configuration reloaded"
        else
            echo "  󰉽  Tmux server not running, skipping"
        fi
    elif [[ "$active_mux" == "zellij" ]]; then
        echo "  󰄬  Zellij configuration will apply on next session start"
    else
        echo "  󰉽  No active multiplexer detected"
    fi

    echo "󰔄  [4/4] Restarting multiplexer..."
    if [[ "$active_mux" == "tmux" ]]; then
        local old_session
        old_session=$(tmux display-message -p '#S' 2>/dev/null) || old_session="Main"
        tmux run-shell -b '~/.tmux/plugins/tmux-resurrect/scripts/save.sh' 2>/dev/null
        local temp_session="reload-$$"
        tmux new-session -d -s "$temp_session" 2>/dev/null
        tmux switch-client -t "$temp_session" 2>/dev/null
        tmux kill-session -t "$old_session" 2>/dev/null
        tmux rename-session -t "$temp_session" "$old_session" 2>/dev/null
        echo "  󰄬  Tmux restarted with fresh \"$old_session\" session"
    elif [[ "$active_mux" == "zellij" ]]; then
        local session_name="${ZELLIJ_SESSION_NAME:-main}"
        echo "  󰄬  Zellij session terminated. Run 'zellij' to restart."
        zellij kill-session "$session_name" 2>/dev/null
    else
        echo "  󰉽  No active multiplexer to restart"
    fi

    echo ""
    echo "󰄬  Full reload complete."
}

function dot-reload-apply() {
    local shell_flag=false
    local settings_flag=false
    local mux_config_flag=false
    local restart_mux_flag=false

    while [[ $# -gt 0 ]]; do
        case "$1" in
            --shell) shell_flag=true ;;
            --settings) settings_flag=true ;;
            --mux-config) mux_config_flag=true ;;
            --restart-mux) restart_mux_flag=true ;;
        esac
        shift
    done

    local step=0
    local total=0
    [[ "$shell_flag" == "true" ]] && ((total++))
    [[ "$settings_flag" == "true" ]] && ((total++))
    [[ "$mux_config_flag" == "true" ]] && ((total++))
    [[ "$restart_mux_flag" == "true" ]] && ((total++))

    echo ""
    [[ "$shell_flag" == "true" ]] && { ((step++)); echo "󰔄  [$step/$total] Reloading shell configs..."; dot-reload-shell; }
    [[ "$settings_flag" == "true" ]] && { ((step++)); echo "󰔄  [$step/$total] Reloading PolyTerm settings..."; dot-reload-settings; }
    [[ "$mux_config_flag" == "true" ]] && { ((step++)); echo "󰔄  [$step/$total] Reloading multiplexer config..."; dot-reload-mux-config; }
    [[ "$restart_mux_flag" == "true" ]] && { ((step++)); echo "󰔄  [$step/$total] Restarting multiplexer..."; dot-restart-mux; }
    echo ""
}

function dot-reload-interactive() {
    echo "󰔄  Starting interactive reload..."
    dot-reload-apply --shell --settings --mux-config --restart-mux
}

function dot-reload-shell() {
    echo "󰍬  Sourcing shell configurations..."
    [[ -f "$HOME/.zshrc" ]] && source "$HOME/.zshrc" 2>/dev/null && echo "  󰄬  .zshrc sourced"

    local saved_ps1="$PS1"
    [[ -f "$HOME/.bashrc" ]] && source "$HOME/.bashrc" 2>/dev/null && echo "  󰄬  .bashrc sourced"
    PS1="$saved_ps1"

    local sync_sh="${DOTFILES_ROOT}/common/palette/sync.sh"
    [[ -f "$sync_sh" ]] && source "$sync_sh" 2>/dev/null
    echo "󰄬  Shell configs reloaded."
}

function dot-reload-settings() {
    echo "󰒓  Reloading PolyTerm environment..."
    local data_path="${DOTFILES_DATA:-${DOTFILES_ROOT}/../polyterm-data}"
    local settings_file="${data_path}/settings/.polyterm_settings"
    [[ -f "$settings_file" ]] && source "$settings_file" 2>/dev/null && echo "  󰄬  PolyTerm settings reloaded"
    echo "󰄬  Settings reloaded."
}

function dot-reload-mux-config() {
    echo "󰒹  Reloading multiplexer configuration..."
    local active_mux=""
    [[ -n "$TMUX" ]] && active_mux="tmux"
    [[ -n "$ZELLIJ" ]] && active_mux="zellij"

    if [[ "$active_mux" == "tmux" ]]; then
        if tmux info &>/dev/null 2>&1; then
            tmux set-environment -g DOTFILES_ROOT "${DOTFILES_ROOT}" 2>/dev/null
            tmux source-file "$HOME/.tmux.conf" 2>/dev/null && echo "  󰄬  Tmux configuration reloaded"
        else
            echo "  󰉽  Tmux server not running, skipping"
        fi
    elif [[ "$active_mux" == "zellij" ]]; then
        echo "  󰄬  Zellij configuration will apply on next session start"
    else
        echo "  󰉽  No active multiplexer detected"
    fi
    echo "󰄬  Multiplexer config reloaded."
}

function dot-restart-mux() {
    echo "󰒠  Restarting multiplexer..."
    local active_mux=""
    [[ -n "$TMUX" ]] && active_mux="tmux"
    [[ -n "$ZELLIJ" ]] && active_mux="zellij"

    if [[ "$active_mux" == "tmux" ]]; then
        local old_session
        old_session=$(tmux display-message -p '#S' 2>/dev/null) || old_session="Main"
        tmux run-shell -b '~/.tmux/plugins/tmux-resurrect/scripts/save.sh' 2>/dev/null
        local temp_session="reload-$$"
        tmux new-session -d -s "$temp_session" 2>/dev/null
        tmux switch-client -t "$temp_session" 2>/dev/null
        tmux kill-session -t "$old_session" 2>/dev/null
        tmux rename-session -t "$temp_session" "$old_session" 2>/dev/null
        echo "  󰄬  Tmux restarted with fresh \"$old_session\" session"
    elif [[ "$active_mux" == "zellij" ]]; then
        local session_name="${ZELLIJ_SESSION_NAME:-main}"
        echo "  󰄬  Zellij session terminated. Run 'zellij' to restart."
        zellij kill-session "$session_name" 2>/dev/null
    else
        echo "  󰉽  No active multiplexer to restart"
    fi
    echo "󰄬  Multiplexer restarted."
}
