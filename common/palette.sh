#!/bin/bash

# Configuration
BREWFILE_PATH="$HOME/dotfiles/wsl/Brewfile"
DOTFILES_DIR="$HOME/dotfiles"
TARGET_PANE=$(tmux display-message -p '#{pane_id}')

function main_menu() {
    options="1. 🚀 Apps (Launch)
2. 📦 Install New App (Brew)
3. 🔄 Refresh Tmux/Plugins
4. ⬆️  Sync Dotfiles (Push)
5. ❌ Exit"

    choice=$(echo -e "$options" | fzf --prompt="󱂬 Cockpit > " --height=100% --layout=reverse --border)

    case "$choice" in
        *1.*) apps_menu ;;
        *2.*) install_app ;;
        *3.*) reload_tmux ;;
        *4.*) sync_dots ;;
        *) exit 0 ;;
    esac
}

function install_app() {
    echo -n "Enter package name to install: "
    read -r app_name
    
    if [[ -z "$app_name" ]]; then
        main_menu
        return
    fi

    echo "--- Installing $app_name ---"
    if brew install "$app_name"; then
        echo "✅ Success! Updating Brewfile..."
        # Safely regenerate the Brewfile from actual installed apps
        # --force overwrites the old file, --describe adds comments
        brew bundle dump --file="$BREWFILE_PATH" --force --describe
        
        echo "📦 Brewfile updated. Initiating Sync..."
        sync_dots
    else
        echo "❌ Installation failed. Brewfile not updated."
        read -p "Press Enter to return..."
    fi
    main_menu
}

function sync_dots() {
    # Since dot-sync is a Zsh function, we call it via zsh -c
    # This ensures your existing Git logic is reused.
    tmux send-keys -t "$TARGET_PANE" "dot-sync" C-m
    echo "Sync command sent to terminal."
    sleep 2
}

function apps_menu() {
    if [[ ! -f "$BREWFILE_PATH" ]]; then
        echo "Brewfile not found at $BREWFILE_PATH"
        sleep 2; main_menu; return
    fi

    app_choice=$(grep '^brew ' "$BREWFILE_PATH" | sed 's/brew "\(.*\)"/\1/' | fzf --prompt=" Launch > " --height=100% --layout=reverse)

    if [[ -n "$app_choice" ]]; then
        tmux send-keys -t "$TARGET_PANE" "$app_choice" C-m
    else
        main_menu
    fi
}

function reload_tmux() {
    tmux source-file ~/.tmux.conf
    ~/.tmux/plugins/tpm/bin/install_plugins
    tmux display-message "Tmux Reloaded!"
}

main_menu