#!/bin/bash

# --- Helper: Get the current pane for send-keys ---
# We want to send shell commands to the pane that was active BEFORE the popup opened.
TARGET_PANE=$(tmux display-message -p '#{pane_id}')

function main_menu() {
    options="1. 🔄 Refresh Plugins & Reload Tmux
2. ⬇️  Pull Dotfiles (dot-pull)
3. ⬆️  Sync Dotfiles (dot-sync)
4. 🐚 Reload Zsh (~/.zshrc)
5. 🐳 Docker Menu
6. 📊 System Monitor (btop)
7. ❌ Exit"

    # Run fzf
    choice=$(echo -e "$options" | fzf --prompt="󱂬 Command Palette > " --height=100% --layout=reverse --border --header="Select an action")

    case "$choice" in
        *1.*) # Refresh Plugins & Reload Tmux
            tmux source-file ~/.tmux.conf
            # This triggers TPM to install/clean plugins non-interactively
            ~/.tmux/plugins/tpm/bin/install_plugins
            tmux display-message "Tmux Config & Plugins Reloaded!"
            ;;
        *2.*) # dot-pull
            # We execute this directly in the popup so you can see the git output
            cd ~/dotfiles && git pull origin main
            tmux send-keys -t "$TARGET_PANE" "source ~/.zshrc" C-m
            read -p "Press Enter to close..."
            ;;
        *3.*) # dot-sync
            cd ~/dotfiles
            git add -A
            git commit -m "Manual sync via palette: $(date +'%Y-%m-%d %H:%M')"
            git push origin main
            read -p "Press Enter to close..."
            ;;
        *4.*) # Reload Zsh
            # We send the command to the active pane so it actually updates your shell
            tmux send-keys -t "$TARGET_PANE" "source ~/.zshrc && echo 'Zsh reloaded.'" C-m
            ;;
        *5.*) docker_menu ;;
        *6.*) tmux send-keys -t "$TARGET_PANE" "btop" C-m ;;
        *) exit 0 ;;
    esac
}

function docker_menu() {
    docker_options="1. View Containers (ps)\n2. Prune System\n3. Back to Main Menu"
    choice=$(echo -e "$docker_options" | fzf --prompt=" Docker > " --height=100% --layout=reverse --border)
    
    case "$choice" in
        *1.*) tmux send-keys -t "$TARGET_PANE" "docker ps" C-m ;;
        *2.*) tmux send-keys -t "$TARGET_PANE" "docker system prune -a" C-m ;;
        *3.*) main_menu ;;
    esac
}

# Start the engine
main_menu