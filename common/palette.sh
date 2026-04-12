#!/bin/bash

# Path to your Brewfile - adjusting based on your dotfiles structure
BREWFILE="$HOME/dotfiles/Brewfile"
TARGET_PANE=$(tmux display-message -p '#{pane_id}')

function main_menu() {
    options="1. 🚀 Apps (from Brewfile)
2. 🔄 Refresh Plugins & Reload Tmux
3. ⬇️  Dot-Pull (Git Pull)
4. ⬆️  Dot-Sync (Git Push)
5. 🐚 Source Zsh (~/.zshrc)
6. ❌ Exit"

    choice=$(echo -e "$options" | fzf --prompt="󱂬 Main Menu > " --height=100% --layout=reverse --border)

    case "$choice" in
        *1.*) apps_menu ;;
        *2.*) 
            tmux source-file ~/.tmux.conf
            ~/.tmux/plugins/tpm/bin/install_plugins
            tmux display-message "Tmux Reloaded!" ;;
        *3.*) 
            cd ~/dotfiles && git pull
            tmux send-keys -t "$TARGET_PANE" "source ~/.zshrc" C-m
            read -p "Pull complete. Press Enter..." ;;
        *4.*) 
            cd ~/dotfiles && git add . && git commit -m "sync: $(date)" && git push
            read -p "Sync complete. Press Enter..." ;;
        *5.*) 
            tmux send-keys -t "$TARGET_PANE" "source ~/.zshrc && echo 'Zsh reloaded.'" C-m ;;
        *) exit 0 ;;
    esac
}

function apps_menu() {
    # 1. Grab lines starting with 'brew' 
    # 2. Extract the name between the quotes
    # 3. Present in fzf
    if [[ ! -f "$BREWFILE" ]]; then
        echo "Brewfile not found at $BREWFILE"
        sleep 2
        main_menu
    fi

    app_choice=$(grep '^brew ' "$BREWFILE" | sed 's/brew "\(.*\)"/\1/' | fzf --prompt=" Launch App > " --height=100% --layout=reverse --border --header="Select a CLI tool to run")

    if [[ -n "$app_choice" ]]; then
        # Send the app name to the original pane and press Enter (C-m)
        tmux send-keys -t "$TARGET_PANE" "$app_choice" C-m
    else
        main_menu
    fi
}

main_menu