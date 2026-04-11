#!/bin/bash

# Main Menu Options
function main_menu() {
    # Use a newline-separated string for fzf to parse correctly
    options="1. Reload Tmux Config\n2. Session Manager\n3. Docker Tools\n4. System Monitor (btop)\n5. Close All Other Panes\n6. Exit"
    
    # Capture choice without the space-after-equals syntax error [cite: 41]
    choice=$(echo -e "$options" | fzf --prompt=" Command Palette > " \
        --height=100% --layout=reverse --border \
        --header="Select a command or type to search")

    case "$choice" in
        *Reload*) 
            tmux source-file ~/.tmux.conf && tmux display-message "Config Reloaded!"  
            ;;
        *Session*) 
            session_menu 
            ;;
        *Docker*) 
            docker_menu 
            ;;
        *btop*) 
            tmux new-window "btop" 
            ;;
        *Close*) 
            tmux kill-pane -a 
            ;;
        *) 
            exit 0 
            ;;
    esac
}

# Drill-down: Docker Menu
function docker_menu() {
    options="1. View Containers (ps)\n2. Prune System\n3. Back to Main Menu"
    choice=$(echo -e "$options" | fzf --prompt=" Docker > " --height=100% --layout=reverse --border)

    case "$choice" in
        *View*) 
            tmux split-window -h "docker ps; read" 
            ;;
        *Prune*) 
            tmux split-window -h "docker system prune; read" 
            ;;
        *Back*) 
            main_menu # Drill-back logic [cite: 5, 6]
            ;;
        *)
            main_menu
            ;;
    esac
}

# Drill-down: Session Menu
function session_menu() {
    # Lists sessions and allows switching [cite: 6, 7]
    choice=$(tmux list-sessions -F "#S" | fzf --prompt="󱂬 Switch Session > " --height=100% --layout=reverse --border)
    
    if [ -n "$choice" ]; then
        tmux switch-client -t "$choice"
    else
        main_menu # Drill-back if Esc is pressed [cite: 7]
    fi
}

# Start the engine
main_menu
