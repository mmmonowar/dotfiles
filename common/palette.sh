#!/bin/bash

# ==========================================
# 🎛️ TMUX COMMAND PALETTE (Merged & Upgraded)
# ==========================================

# 1. Capture the pane ID where the palette was triggered
TARGET_PANE=$(tmux display-message -p '#{pane_id}')

# 2. OS Detection for cross-platform dotfiles
if uname -a | grep -iq "microsoft\|wsl"; then
    OS_ENV="wsl"
elif [[ "$OSTYPE" == "darwin"* ]]; then
    OS_ENV="mac"
else
    OS_ENV="linux" # Fallback for native Linux
fi

# 3. Dynamic Paths
BREWFILE_PATH="$HOME/dotfiles/${OS_ENV}/Brewfile"
META_PATH="$HOME/dotfiles/${OS_ENV}/apps_meta.txt"

# ==========================================
# 🛠️ HELPER FUNCTIONS
# ==========================================

function trigger_zsh_func() {
    local func_name=$1
    # Send the command to the original pane and execute it
    tmux send-keys -t "$TARGET_PANE" "$func_name" C-m
}

function get_app_description() {
    local app_name="$1"
    # Look for the exact app name in the sidecar file
    if [[ -f "$META_PATH" ]]; then
        local desc=$(grep "^${app_name}|" "$META_PATH" | cut -d'|' -f2-)
        if [[ -n "$desc" ]]; then
            echo "$desc"
            return
        fi
    fi
    # Fallback if no description exists
    echo "⚙️ CLI Tool"
}

# ==========================================
# 📦 PACKAGE MANAGEMENT
# ==========================================

function install_app() {
    clear
    echo "📦 Install App (via Homebrew)"
    echo "-----------------------------"
    read -p "Enter package name (or press Enter to cancel): " app_name
    
    if [[ -z "$app_name" ]]; then
        main_menu
        return
    fi
    
    # Send install command to target pane
    trigger_zsh_func "brew install $app_name"
}

function uninstall_app() {
    if [[ ! -f "$BREWFILE_PATH" ]]; then
        echo "❌ Brewfile not found at $BREWFILE_PATH!"
        sleep 2
        main_menu
        return
    fi

    # Parse Brewfile and use fzf to select what to uninstall
    local apps=($(grep '^brew "' "$BREWFILE_PATH" | cut -d '"' -f 2))
    local list_items=""
    for app in "${apps[@]}"; do
        list_items+="$app\n"
    done

    local selection=$(echo -e "$list_items" | fzf \
        --height 100% \
        --reverse \
        --border rounded \
        --prompt "🗑️ " \
        --header "Select App to Uninstall")

    if [[ -n "$selection" ]]; then
        trigger_zsh_func "brew uninstall $selection"
    else
        main_menu
    fi
}

function reload_tmux() {
    tmux source-file ~/.tmux.conf
    ~/.tmux/plugins/tpm/bin/install_plugins
    tmux display-message "✅ Tmux Reloaded & Plugins Installed!"
}

# ==========================================
# 🚀 MENU LOGIC
# ==========================================

function apps_menu() {
    if [[ ! -f "$BREWFILE_PATH" ]]; then
        echo -e "❌ Brewfile missing at:\n$BREWFILE_PATH"
        sleep 2
        main_menu
        return
    fi

    # Parse the Brewfile: Extract exact package names
    local apps=($(grep '^brew "' "$BREWFILE_PATH" | cut -d '"' -f 2))

    # Build the list with descriptions
    local list_items=""
    for app in "${apps[@]}"; do
        local desc=$(get_app_description "$app")
        list_items+="$app | $desc\n"
    done

    # fzf UI for Apps
    local selection=$(echo -e "$list_items" | fzf \
        --height 100% \
        --reverse \
        --border rounded \
        --prompt "⚡ " \
        --header "🚀 Launch App (Brewfile: $OS_ENV)" \
        --delimiter ' \| ' \
        --with-nth 1,2)

    # Execution or back out
    if [[ -n "$selection" ]]; then
        local selected_app=$(echo "$selection" | cut -d '|' -f 1 | xargs)
        trigger_zsh_func "$selected_app"
    else
        main_menu
    fi
}

function main_menu() {
    # Define main menu options mirroring your original configuration
    local menu_options="1 | 🚀 Apps (Launch)\n2 | 📦 Install App\n3 | 🗑️ Uninstall App\n4 | ⬇️ Pull Remote Changes\n5 | ⬆️ Push Local Changes (Sync)\n6 | 🔄 Refresh Tmux\n7 | ❌ Exit"

    # fzf UI for Main Menu
    local selection=$(echo -e "$menu_options" | fzf \
        --height 100% \
        --reverse \
        --border rounded \
        --prompt "❯ " \
        --header "🎛️ Command Palette ($OS_ENV)" \
        --delimiter ' \| ' \
        --with-nth 2)

    # Extract the ID
    local choice=$(echo "$selection" | cut -d '|' -f 1 | xargs)

    # Route the choice
    case "$choice" in
        1) apps_menu ;;
        2) install_app ;;
        3) uninstall_app ;;
        4) trigger_zsh_func "dot-pull" ;;
        5) trigger_zsh_func "dot-sync" ;;
        6) reload_tmux ;;
        7|*) exit 0 ;;
    esac
}

# ==========================================
# 🏁 INITIALIZATION
# ==========================================

main_menu