#!/bin/bash

# Main Menu Options
function main_menu() {
  options="1. Reload Tmux Config\n2. Session Manager\n3. Docker Tools\n4. System Monitor (btop)\n5. Close All Other Panes\n6. Exit"
  
  choice=$(echo -e "$options" | fzf --prompt=" Command Palette > " --height=100% --layout=reverse --border --header="Select a command or type to search")

  case $choice in
    *Reload*) tmux source-file ~/.tmux.conf && tmux display-message "Config Reloaded!" ;; # 
    *Session*) session_menu ;;
    *Docker*) docker_menu ;;
    *btop*) tmux new-window "btop" ;; # 
    *Close*) tmux kill-pane -a ;;
    *) exit 0 ;;
  esac
}

# Drill-down: Docker Menu
function docker_menu() {
  options="1. View Containers (ps)\n2. Prune System\n3. Back to Main Menu"
  choice=$(echo -e "$options" | fzf --prompt=" Docker > " --height=100% --layout=reverse --border)

  case $choice in
    *View*) tmux split-window -h "docker ps; read" ;;
    *Prune*) tmux split-window -h "docker system prune; read" ;;
    *Back*) main_menu ;;
  esac
}

# Drill-down: Session Menu
function session_menu() {
  choice=$(tmux list-sessions -F "#S" | fzf --prompt="󱂬 Switch Session > " --height=100% --layout=reverse --border)
  if [ -n "$choice" ]; then
    tmux switch-client -t "$choice"
  else
    main_menu
  fi
}

main_menu
