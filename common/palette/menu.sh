#!/bin/bash

# ==========================================
# 🚀  CORE MENU LOGIC
# ==========================================

function list_all_items() {
    local query=$1
    local dim="\033[2m"
    local reset="\033[0m"
    local mod="Alt"
    local idx=0

    if [[ -z "$query" ]]; then
        # Hierarchical Main Menu
        echo -e "1 | 󱓞  Launch App... | ${dim}Browse and launch installed CLI tools${reset} | CAT | apps"
        echo -e "2 | 󰈙  Project Documents... | ${dim}Read all documentation in project-manager/${reset} | CAT | docs"
        echo -e "3 | 󰒓  Settings... | ${dim}Tweak security and UX preferences${reset} | CAT | settings"
        echo -e "4 |   Execute Shortcut... | ${dim}Run Tmux window and pane commands${reset} | CAT | shortcuts"
        echo -e "5 | 󰈙  Scratchpad | ${dim}Open worklog scratch-pad in micro${reset} | ACTION | scratchpad"
        echo -e "6 | 󰏔  Install App | ${dim}Install new packages via Homebrew${reset} | ACTION | install"
        echo -e "7 | 󰆴  Uninstall App | ${dim}Remove packages and sync to GitHub${reset} | ACTION | uninstall"
        echo -e "8 | 󰇚  Pull Changes | ${dim}Fetch latest updates from GitHub${reset} | ACTION | pull"
        echo -e "9 | 󰇶  Push Changes | ${dim}Sync local configs to GitHub (Self-Healing)${reset} | ACTION | push"
        echo -e "10 |   Reload All Configs | ${dim}Refresh Zsh and Tmux environments${reset} | ACTION | reload"
        echo -e "11 | 󰒃  Security Scan | ${dim}Run audit and package vulnerability checks${reset} | ACTION | scan"
        echo -e "12 | 󰌌  Fix Alt Keys | ${dim}Diagnose and resolve keyboard issues${reset} | ACTION | fix_alt"
        echo -e "13 | 󰅙  Exit | ${dim}Close the command palette${reset} | ACTION | exit"
    else
        # Flattened Global Discovery
        # 1. Apps
        if [[ -f "$META_PATH" ]]; then
            while IFS='|' read -r app desc; do
                ((idx++))
                echo -e "$idx | 󱓞  $app | ${dim}$desc${reset} | APP | $app"
            done < "$META_PATH"
        fi
        # 2. Documents
        local docs_path="${REPO_PATH}/project-manager"
        if [[ -d "$docs_path" ]]; then
            while IFS= read -r file; do
                ((idx++))
                local rel_path="${file#$docs_path/}"
                local display_name=$(echo "$rel_path" | sed -E 's/\.md$//; s/[\/-]/ /g; s/\b(.)/\u\1/g')
                echo -e "$idx | 󰈙  $display_name | ${dim}Read $rel_path${reset} | DOC | $file"
            done < <(find "$docs_path" -type f -name "*.md" | sort)
        fi
        # 3. Settings
        local scan_push_status="[OFF]"; [[ "$POLYTERM_SCAN_ON_PUSH" == "true" ]] && scan_push_status="[ON]"
        local scan_pull_status="[OFF]"; [[ "$POLYTERM_SCAN_ON_PULL" == "true" ]] && scan_pull_status="[ON]"
        ((idx++)); echo -e "$idx | 󰒃  Security Check on Push $scan_push_status | ${dim}Toggle pre-push scan${reset} | SETTING | SCAN_PUSH"
        ((idx++)); echo -e "$idx | 󰒃  Security Check on Pull $scan_pull_status | ${dim}Toggle post-pull scan${reset} | SETTING | SCAN_PULL"
        ((idx++)); echo -e "$idx | 󰈙  Scratchpad Settings | ${dim}Configure paths and access${reset} | ACTION | scratchpad_settings"
        # 4. Scratchpad
        ((idx++)); echo -e "$idx | 󰈙  Scratchpad | ${dim}Open worklog scratch-pad in micro${reset} | ACTION | scratchpad"
        # 5. Shortcuts
        ((idx++)); echo -e "$idx | 󰐕  New Session ($mod+,) | ${dim}Create fresh session${reset} | SHORTCUT | new-session"
        ((idx++)); echo -e "$idx | 󰑐  Cycle Sessions ($mod+0) | ${dim}Switch next session${reset} | SHORTCUT | switch-client -n"
        ((idx++)); echo -e "$idx | 󰆴  Kill Session ($mod+w) | ${dim}Terminate session${reset} | SHORTCUT | kill-session"
        ((idx++)); echo -e "$idx | 󰈔  New Window ($mod+m) | ${dim}Create new window${reset} | SHORTCUT | new-window"
        ((idx++)); echo -e "$idx | 󰅙  Kill Window ($mod+e) | ${dim}Close window${reset} | SHORTCUT | kill-window"
        # 6. Actions
        ((idx++)); echo -e "$idx | 󰏔  Install App | ${dim}Install via Homebrew${reset} | ACTION | install"
        ((idx++)); echo -e "$idx | 󰆴  Uninstall App | ${dim}Remove and sync${reset} | ACTION | uninstall"
        ((idx++)); echo -e "$idx | 󰇚  Pull Changes | ${dim}Fetch from GitHub${reset} | ACTION | pull"
        ((idx++)); echo -e "$idx | 󰇶  Push Changes | ${dim}Sync to GitHub${reset} | ACTION | push"
        ((idx++)); echo -e "$idx |   Reload All Configs | ${dim}Refresh env${reset} | ACTION | reload"
        ((idx++)); echo -e "$idx | 󰒃  Security Scan | ${dim}Run audit${reset} | ACTION | scan"
    fi
}

function main_menu() {
    local selection=$(list_all_items "" | fzf \
        --ansi \
        --height 100% \
        --reverse \
        --border rounded \
        --prompt "  " \
        --header "Search Palette (Type index or keywords)" \
        --delimiter ' \| ' \
        --with-nth 1,2,3 \
        --info=inline \
        --bind "change:reload($0 --list {q})")

    if [[ -z "$selection" ]]; then exit 0; fi

    local type arg
    if [[ "$selection" =~ ^[0-9]+[[:space:]]+\| ]]; then
        type=$(echo "$selection" | cut -d '|' -f 4 | xargs)
        arg=$(echo "$selection" | cut -d '|' -f 5 | xargs)
    else
        type=$(echo "$selection" | cut -d '|' -f 3 | xargs)
        arg=$(echo "$selection" | cut -d '|' -f 4 | xargs)
    fi

    case "$type" in
        CAT)
            case "$arg" in
                apps) apps_menu ;;
                docs) documents_menu ;;
                settings) settings_menu ;;
                shortcuts) shortcuts_menu ;;
            esac
            ;;
        APP) trigger_zsh_func "$arg" ;;
        DOC) read_document "$arg"; documents_menu ;;
        SETTING)
            case "$arg" in
                SCAN_PUSH) update_setting "POLYTERM_SCAN_ON_PUSH" "$([[ "$POLYTERM_SCAN_ON_PUSH" == "true" ]] && echo false || echo true)" ;;
                SCAN_PULL) update_setting "POLYTERM_SCAN_ON_PULL" "$([[ "$POLYTERM_SCAN_ON_PULL" == "true" ]] && echo false || echo true)" ;;
            esac
            settings_menu
            ;;
        SHORTCUT) execute_shortcut "$arg" ;;
        ACTION)
            case "$arg" in
                scratchpad) open_scratchpad ;;
                scratchpad_settings) scratchpad_menu ;;
                install) install_app ;;
                uninstall) uninstall_app ;;
                pull) trigger_zsh_func "dot-pull" ;;
                push) trigger_zsh_func "dot-sync" ;;
                reload) trigger_zsh_func "source ~/.zshrc && dot-reload" ;;
                scan) trigger_zsh_func "dot-scan" ;;
                kill_gemini) kill_gemini_processes ;;
                fix_alt) clear; "$REPO_PATH/common/fix-alt-keys.sh"; printf "Press Enter to return..."; read -r; main_menu ;;
                exit) exit 0 ;;
            esac
            ;;
    esac
}
              exit) exit 0 ;;
            esac
            ;;
    esac
}
