#!/bin/bash

# ==========================================
#   SHORTCUTS LOGIC
# ==========================================

function shortcuts_menu() {
    local query=$1
    local mod="Alt"
    local dim="\033[2m"
    local reset="\033[0m"

    local menu_items="1 | 󰐕  New Session ($mod+,) | ${dim}Create a fresh tmux session${reset} | new-session
"
    menu_items+="2 | 󰑐  Cycle Sessions ($mod+0) | ${dim}Switch to the next active session${reset} | switch-client -n
"
    menu_items+="3 | 󰆴  Kill Session ($mod+w) | ${dim}Terminate the current session${reset} | kill-session
"
    menu_items+="4 | 󰈔  New Window ($mod+m) | ${dim}Create a new tmux window${reset} | new-window
"
    menu_items+="5 | 󰅙  Kill Window ($mod+e) | ${dim}Close the current window${reset} | kill-window
"
    menu_items+="6 | 󰁞  Next Window ($mod+Up) | ${dim}Switch to the next window${reset} | next-window
"
    menu_items+="7 | 󰁆  Previous Window ($mod+Down) | ${dim}Switch to the previous window${reset} | previous-window
"
    menu_items+="8 | 󰁍  Previous Pane ($mod+Left) | ${dim}Switch to the previous pane${reset} | select-pane -t :.-
"
    menu_items+="9 | 󰁔  Next Pane ($mod+Right) | ${dim}Switch to the next pane${reset} | select-pane -t :.+
"
    menu_items+="10 | 󰐕  Create Pane ($mod+1) | ${dim}Split window and balance layout${reset} | split-window -c "#{pane_current_path}"; select-layout tiled
"
    menu_items+="11 | 󰅖  Close Pane ($mod+2) | ${dim}Close the active pane${reset} | kill-pane; select-layout tiled"

    local selection=$(echo -e "$menu_items" | fzf 
        --ansi 
        --height 100% 
        --reverse 
        --border rounded 
        --prompt "  " 
        --query "$query" 
        --header "Select Shortcut (Type index or name)" 
        --delimiter ' \| ' 
        --with-nth 1,2,3)

    if [[ -n "$selection" ]]; then
        local cmd=$(echo "$selection" | cut -d '|' -f 4 | xargs)
        execute_shortcut "$cmd"
    else
        main_menu
    fi
}

function execute_shortcut() {
    local cmd=$1
    if [[ -n "$ZELLIJ" ]]; then
        case "$cmd" in
            "new-session")
                zellij action new-tab
                ;;
            "switch-client -n")
                zellij action switch-session
                ;;
            "kill-session")
                clear
                if confirm_action "Kill current session?"; then
                    local current_session=$ZELLIJ_SESSION_NAME
                    if [[ -n "$current_session" ]]; then
                        zellij kill-session "$current_session"
                    else
                        exit 0
                    fi
                fi
                ;;
            "new-window")
                zellij action new-tab
                ;;
            "kill-window")
                zellij action close-tab
                ;;
            "next-window")
                zellij action go-to-next-tab
                ;;
            "previous-window")
                zellij action go-to-previous-tab
                ;;
            "select-pane -t :.-")
                zellij action move-focus "Left"
                ;;
            "select-pane -t :.+")
                zellij action move-focus "Right"
                ;;
            *"split-window"*)
                local pane_count
                pane_count=$(zellij action list-panes --json | python3 -c 'import sys, json; print(len([p for p in json.load(sys.stdin) if not p.get("is_floating") and not p.get("is_plugin")]))' 2>/dev/null)
                if [[ -z "$pane_count" || "$pane_count" -lt 4 ]]; then
                    zellij action new-pane
                else
                    echo "Limit reached: 4 panes max"
                    sleep 1
                fi
                ;;
            *"kill-pane"*)
                zellij action close-pane
                ;;
            *)
                zellij action $cmd 2>/dev/null || echo -e "Shortcut not supported in Zellij"
                ;;
        esac
        zellij action close-pane 2>/dev/null
    else
        # Tmux
        if [[ "$cmd" == "kill-session" ]]; then
            clear
            if ! confirm_action "Kill current session?"; then
                shortcuts_menu
                return
            fi
        fi
        # Execute tmux command directly (resolving ISSUE-17 redundancy)
        eval "tmux $cmd"
    fi
}
