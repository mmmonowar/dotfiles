#!/bin/bash

# Configuration
BREWFILE_PATH="$HOME/dotfiles/wsl/Brewfile"
TARGET_PANE=$(tmux display-message -p '#{pane_id}')

function main_menu() {
    # Added Option 3 and 4 for better control
    options="1. 🚀 Apps (Launch)
2. 📦 Install New App (Brew)
3. ⬇️  Pull Remote Changes (Update Local)
4. ⬆️  Push Local Changes (Sync to GitHub)
5. 🔄 Refresh Tmux/Plugins
6. ❌ Exit"

    choice=$(echo -e "$options" | fzf --prompt="󱂬 Cockpit > " --height=100% --layout=reverse --border)

    case "$choice" in
        *1.*) apps_menu ;;
        *2.*) install_app ;;
        *3.*) trigger_zsh_func "dotpull" ;;
        *4.*) trigger_zsh_func "dot-sync" ;;
        *5.*) reload_tmux ;;
        *) exit 0 ;;
    esac
}

# Unified function to send Zsh commands to the active pane
function trigger_zsh_func() {
    local func_name=$1
    echo "Sending $func_name to terminal..."
    tmux send-keys -t "$TARGET_PANE" "$func_name" C-m
    # We don't exit the script so you can see if it worked
}

function install_app() {
    echo -n "Enter package name: "
    read -r app_name
    
    if [[ -n "$app_name" ]]; then
        # Use your existing Zsh logic via tmux to keep everything in one history
        tmux send-keys -t "$TARGET_PANE" "brew install $app_name && brew bundle dump --file=$BREWFILE_PATH --force && dot-sync" C-m
        echo "Installation and Sync command queued."
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