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
        printf "%3s │ %-35s │ %b │ %-8s │ %s\n" "1" "󱓞  Launch App..." "${dim}Browse and launch installed CLI tools${reset}" "CAT" "apps"
        printf "%3s │ %-35s │ %b │ %-8s │ %s\n" "2" "󰈙  Project Documents..." "${dim}Read project documentation${reset}" "CAT" "docs"
        printf "%3s │ %-35s │ %b │ %-8s │ %s\n" "3" "󰒓  Settings..." "${dim}Tweak security and UX preferences${reset}" "CAT" "settings"
        printf "%3s │ %-35s │ %b │ %-8s │ %s\n" "4" "  Execute Shortcut..." "${dim}Run Tmux window and pane commands${reset}" "CAT" "shortcuts"
        printf "%3s │ %-35s │ %b │ %-8s │ %s\n" "5" "󰒓  PolyOS-dev..." "${dim}Manage PolyOS dev repos and tools${reset}" "CAT" "polyos_dev"
        printf "%3s │ %-35s │ %b │ %-8s │ %s\n" "6" "󰈙  Scratchpad" "${dim}Open worklog scratch-pad in micro${reset}" "ACTION" "scratchpad"
        printf "%3s │ %-35s │ %b │ %-8s │ %s\n" "7" "󰏔  Install App" "${dim}Install new packages via Homebrew${reset}" "ACTION" "install"
        printf "%3s │ %-35s │ %b │ %-8s │ %s\n" "8" "󰆴  Uninstall App" "${dim}Remove packages and sync to GitHub${reset}" "ACTION" "uninstall"
        printf "%3s │ %-35s │ %b │ %-8s │ %s\n" "9" "󰇚  Pull Changes" "${dim}Fetch latest updates from GitHub${reset}" "ACTION" "pull"
        printf "%3s │ %-35s │ %b │ %-8s │ %s\n" "10" "󰇶  Push Changes" "${dim}Sync configs to GitHub${reset}" "ACTION" "push"
        printf "%3s │ %-35s │ %b │ %-8s │ %s\n" "11" "  Reload Configs..." "${dim}Selectively refresh shell, settings, or mux${reset}" "SUBCAT" "reload"
        printf "%3s │ %-35s │ %b │ %-8s │ %s\n" "12" "󰒃  Security Scan" "${dim}Run audit and vulnerability checks${reset}" "ACTION" "scan"
        printf "%3s │ %-35s │ %b │ %-8s │ %s\n" "13" "󰌌  Fix Alt Keys" "${dim}Diagnose and resolve keyboard issues${reset}" "ACTION" "fix_alt"
        printf "%3s │ %-35s │ %b │ %-8s │ %s\n" "14" "󰖟  Device Manager..." "${dim}Scan, manage, SSH into devices${reset}" "CAT" "devices"
        printf "%3s │ %-35s │ %b │ %-8s │ %s\n" "15" "󰒓  Configuration Manager..." "${dim}Manage app configs (Zellij)${reset}" "CAT" "config"
        printf "%3s │ %-35s │ %b │ %-8s │ %s\n" "16" "󰅙  Exit" "${dim}Close the command palette${reset}" "ACTION" "exit"
    else
        # Flattened Global Discovery with Category Headers
        local cyan="\033[36m"
        local bold="\033[1m"
        local header_reset="\033[0m"

        # ──── APPS ────
        if [[ -f "$META_PATH" ]]; then
            echo -e "${cyan}──── APPS${header_reset}"
            while IFS='|' read -r app desc; do
                ((idx++))
                printf "%3s │ %-35s │ %b │ %-8s │ %s\n" "$idx" "󱓞  $app" "${dim}$(truncate_desc "$desc")${reset}" "APP" "$app"
            done < "$META_PATH"
        fi
        # ──── DOCUMENTS ────
        local docs_path="$DOCS_PATH"
        if [[ -n "$docs_path" && -d "$docs_path" ]]; then
            echo -e "${cyan}──── DOCUMENTS${header_reset}"
            while IFS= read -r file; do
                ((idx++))
                local rel_path="${file#$docs_path/}"
                local display_name=$(echo "$rel_path" | sed -E 's/\.md$//; s/[\/-]/ /g; s/\b(.)/\u\1/g')
                printf "%3s │ %-35s │ %b │ %-8s │ %s\n" "$idx" "󰈙  $display_name" "${dim}$(truncate_desc "Read $rel_path")${reset}" "DOC" "$file"
            done < <(find "$docs_path" -type f -name "*.md" | sort)
        fi
        # ──── SETTINGS ────
        echo -e "${cyan}──── SETTINGS${header_reset}"
        local scan_push_status="[OFF]"; [[ "$POLYTERM_SCAN_ON_PUSH" == "true" ]] && scan_push_status="[ON]"
        local scan_pull_status="[OFF]"; [[ "$POLYTERM_SCAN_ON_PULL" == "true" ]] && scan_pull_status="[ON]"
        ((idx++)); printf "%3s │ %-35s │ %b │ %-8s │ %s\n" "$idx" "󰒃  Security Check on Push $scan_push_status" "${dim}Toggle pre-push scan${reset}" "SETTING" "SCAN_PUSH"
        ((idx++)); printf "%3s │ %-35s │ %b │ %-8s │ %s\n" "$idx" "󰒃  Security Check on Pull $scan_pull_status" "${dim}Toggle post-pull scan${reset}" "SETTING" "SCAN_PULL"
        ((idx++)); printf "%3s │ %-35s │ %b │ %-8s │ %s\n" "$idx" "󰈙  Scratchpad Settings" "${dim}Configure paths and access${reset}" "ACTION" "scratchpad_settings"
        # ──── SCRATCHPAD ────
        echo -e "${cyan}──── SCRATCHPAD${header_reset}"
        ((idx++)); printf "%3s │ %-35s │ %b │ %-8s │ %s\n" "$idx" "󰈙  Scratchpad" "${dim}Open worklog scratch-pad in micro${reset}" "ACTION" "scratchpad"
        # ──── SHORTCUTS ────
        echo -e "${cyan}──── SHORTCUTS${header_reset}"
        ((idx++)); printf "%3s │ %-35s │ %b │ %-8s │ %s\n" "$idx" "󰐕  New Session ($mod+,)" "${dim}Create fresh session${reset}" "SHORTCUT" "new-session"
        ((idx++)); printf "%3s │ %-35s │ %b │ %-8s │ %s\n" "$idx" "󰑐  Cycle Sessions ($mod+0)" "${dim}Switch next session${reset}" "SHORTCUT" "switch-client -n"
        ((idx++)); printf "%3s │ %-35s │ %b │ %-8s │ %s\n" "$idx" "󰆴  Kill Session ($mod+w)" "${dim}Terminate session${reset}" "SHORTCUT" "kill-session"
        ((idx++)); printf "%3s │ %-35s │ %b │ %-8s │ %s\n" "$idx" "󰈔  New Window ($mod+m)" "${dim}Create new window${reset}" "SHORTCUT" "new-window"
        ((idx++)); printf "%3s │ %-35s │ %b │ %-8s │ %s\n" "$idx" "󰅙  Kill Window ($mod+e)" "${dim}Close window${reset}" "SHORTCUT" "kill-window"
        # ──── ACTIONS ────
        echo -e "${cyan}──── ACTIONS${header_reset}"
        ((idx++)); printf "%3s │ %-35s │ %b │ %-8s │ %s\n" "$idx" "󰏔  Install App" "${dim}Install via Homebrew${reset}" "ACTION" "install"
        ((idx++)); printf "%3s │ %-35s │ %b │ %-8s │ %s\n" "$idx" "󰆴  Uninstall App" "${dim}Remove and sync${reset}" "ACTION" "uninstall"
        ((idx++)); printf "%3s │ %-35s │ %b │ %-8s │ %s\n" "$idx" "󰇚  Pull Changes" "${dim}Fetch from GitHub${reset}" "ACTION" "pull"
        ((idx++)); printf "%3s │ %-35s │ %b │ %-8s │ %s\n" "$idx" "󰇶  Push Changes" "${dim}Sync to GitHub${reset}" "ACTION" "push"
        ((idx++)); printf "%3s │ %-35s │ %b │ %-8s │ %s\n" "$idx" "󰇚  poly-sync" "${dim}Clone or update PolyOS repos from GitHub${reset}" "ACTION" "poly-sync"
        ((idx++)); printf "%3s │ %-35s │ %b │ %-8s │ %s\n" "$idx" "  Reload Configs..." "${dim}Selectively refresh configs${reset}" "SUBCAT" "reload"
        ((idx++)); printf "%3s │ %-35s │ %b │ %-8s │ %s\n" "$idx" "󰒃  Security Scan" "${dim}Run audit${reset}" "ACTION" "scan"
        # ──── DEVICES ────
        echo -e "${cyan}──── DEVICES${header_reset}"
        ((idx++)); printf "%3s │ %-35s │ %b │ %-8s │ %s\n" "$idx" "󰖟  Scan Current Device" "${dim}Detect system and update device registry${reset}" "ACTION" "scan_device"
        ((idx++)); printf "%3s │ %-35s │ %b │ %-8s │ %s\n" "$idx" "󰒔  SSH into Device" "${dim}Connect to a registered device${reset}" "ACTION" "ssh_device"
        ((idx++)); printf "%3s │ %-35s │ %b │ %-8s │ %s\n" "$idx" "󰌋  Manual Device Entry" "${dim}Add or update device data${reset}" "ACTION" "manual_device"
        # ──── CONFIG ────
        echo -e "${cyan}──── CONFIGURATION${header_reset}"
        ((idx++)); printf "%3s │ %-35s │ %b │ %-8s │ %s\n" "$idx" "󰒓  Configuration Manager..." "${dim}Manage app configs (Zellij)${reset}" "CAT" "config"
        ((idx++)); printf "%3s │ %-35s │ %b │ %-8s │ %s\n" "$idx" "󰅳  Zellij Config..." "${dim}Edit Zellij configuration settings${reset}" "CAT" "config"
    fi
}

function documents_menu() {
    local docs_path="$DOCS_PATH"
    if [[ -z "$docs_path" || ! -d "$docs_path" ]]; then
        echo -e "󰅙  Documentation path missing at:
$docs_path"
        sleep 2
        main_menu
        return
    fi

    local list_items=""
    local idx=0
    local dim="\033[2m"
    local reset="\033[0m"
    while IFS= read -r file; do
        ((idx++))
        local rel_path="${file#$docs_path/}"
        local display_name=$(echo "$rel_path" | sed -E 's/\.md$//; s/[\/-]/ /g; s/\b(.)/\u\1/g')
        list_items+="$(printf "%3s │ %-35s │ %b │ %-8s │ %s\n" "$idx" "󰈙  $display_name" "${dim}Read $rel_path${reset}" "DOC" "$file")"
    done < <(find "$docs_path" -type f -name "*.md" | sort)
    list_items+="$(printf "%3s │ %-35s │ %b │ %-8s │ %s\n" "$((idx+1))" "󰅙  Back" "${dim}Return to main menu${reset}" "ACTION" "main_menu")"

    local selection=$(echo -e "$list_items" | fzf \
        --ansi \
        --height 100% \
        --reverse \
        --border rounded \
        --prompt "󰈙  " \
        --header "Project Documentation" \
        --delimiter ' │ ' \
        --with-nth '1,2,3')

    if [[ -z "$selection" ]]; then main_menu; return; fi

    local type arg
    type=$(echo "$selection" | awk -F'│' '{print $4}' | xargs)
    arg=$(echo "$selection" | awk -F'│' '{print $5}' | xargs)

    case "$type" in
        DOC) read_document "$arg"; documents_menu ;;
        ACTION) main_menu ;;
    esac
}

function reload_menu() {
    local dim="\033[2m"
    local reset="\033[0m"

    local list_items=""
    list_items+="$(printf "%3s │ %-35s │ %b │ %-8s │ %s\n" "1" "󰍬  Shell configs" "${dim}Source zshrc, bashrc${reset}" "PHASE" "shell")"
    list_items+="$(printf "%3s │ %-35s │ %b │ %-8s │ %s\n" "2" "󰒓  PolyTerm settings" "${dim}Reload environment preferences${reset}" "PHASE" "settings")"
    list_items+="$(printf "%3s │ %-35s │ %b │ %-8s │ %s\n" "3" "󰒹  Multiplexer config" "${dim}Reload tmux/zellij configuration${reset}" "PHASE" "mux_config")"
    list_items+="$(printf "%3s │ %-35s │ %b │ %-8s │ %s\n" "4" "󰒠  Restart multiplexer" "${dim}Create fresh session (saves state)${reset}" "PHASE" "restart_mux")"
    list_items+="$(printf "%3s │ %-35s │ %b │ %-8s │ %s\n" "5" "󰔄  Reload All" "${dim}Run all four reload phases${reset}" "ACTION" "reload_all")"
    list_items+="$(printf "%3s │ %-35s │ %b │ %-8s │ %s\n" "6" "󰅙  Back" "${dim}Return to main menu${reset}" "ACTION" "main_menu")"

    local selected=$(echo -e "$list_items" | fzf \
        --ansi \
        --height 100% \
        --reverse \
        --border rounded \
        --prompt "󰔄  " \
        --header "Select configs to reload (TAB to toggle, ENTER to confirm)" \
        --delimiter ' │ ' \
        --with-nth '1,2,3' \
        --multi \
        --bind "tab:toggle+down" \
        --bind "shift-tab:toggle+up" \
        --bind "ctrl-a:select-all" \
        --bind "ctrl-d:deselect-all")

    if [[ -z "$selected" ]]; then
        main_menu
        return
    fi

    local shell_flag=""
    local settings_flag=""
    local mux_config_flag=""
    local restart_mux_flag=""

    while IFS= read -r line; do
        local type=$(echo "$line" | awk -F'│' '{print $4}' | xargs)
        local arg=$(echo "$line" | awk -F'│' '{print $5}' | xargs)
        case "$arg" in
            shell) shell_flag="--shell" ;;
            settings) settings_flag="--settings" ;;
            mux_config) mux_config_flag="--mux-config" ;;
            restart_mux) restart_mux_flag="--restart-mux" ;;
            reload_all)
                shell_flag="--shell"
                settings_flag="--settings"
                mux_config_flag="--mux-config"
                restart_mux_flag="--restart-mux"
                ;;
            main_menu) main_menu; return ;;
        esac
    done <<< "$selected"

    if [[ -z "$shell_flag" && -z "$settings_flag" && -z "$mux_config_flag" && -z "$restart_mux_flag" ]]; then
        main_menu
        return
    fi

    local cmd="dot-reload-apply $shell_flag $settings_flag $mux_config_flag $restart_mux_flag"
    trigger_zsh_func "$cmd"
}

function polyos_dev_menu() {
    local dim="\033[2m"
    local reset="\033[0m"
    
    local list_items=""
    list_items+="$(printf "%3s │ %-35s │ %b │ %-8s │ %s\n" "1" "󰇚  poly-sync" "${dim}Clone or update all PolyOS repositories from GitHub${reset}" "ACTION" "poly-sync")"
    list_items+="$(printf "%3s │ %-35s │ %b │ %-8s │ %s\n" "2" "󰅙  Back" "${dim}Return to main menu${reset}" "ACTION" "main_menu")"

    local selection=$(echo -e "$list_items" | fzf \
        --ansi \
        --height 100% \
        --reverse \
        --border rounded \
        --prompt "󰒓  " \
        --header "PolyOS Development Tools" \
        --delimiter ' │ ' \
        --with-nth '1,2,3')

    if [[ -z "$selection" ]]; then main_menu; return; fi

    local type arg
    type=$(echo "$selection" | awk -F'│' '{print $4}' | xargs)
    arg=$(echo "$selection" | awk -F'│' '{print $5}' | xargs)

    case "$type" in
        ACTION)
            case "$arg" in
                poly-sync) trigger_zsh_func "poly-sync" ;;
                main_menu) main_menu ;;
            esac
            ;;
    esac
}

function main_menu() {
    local selection=$(list_all_items "" | fzf \
        --ansi \
        --height 100% \
        --reverse \
        --border rounded \
        --prompt "  " \
        --header "Search Palette (Type index or keywords)" \
        --delimiter ' │ ' \
        --with-nth '1,2,3' \
        --info=inline \
        --bind "change:reload(${REPO_PATH}/common/palette/palette.sh --list {q})")

    if [[ -z "$selection" ]]; then exit 0; fi

    local type arg
    if [[ "$selection" =~ ^[[:space:]]*[0-9]+[[:space:]]+│ ]]; then
        type=$(echo "$selection" | awk -F'│' '{print $4}' | xargs)
        arg=$(echo "$selection" | awk -F'│' '{print $5}' | xargs)
    else
        type=$(echo "$selection" | awk -F'│' '{print $3}' | xargs)
        arg=$(echo "$selection" | awk -F'│' '{print $4}' | xargs)
    fi

    case "$type" in
        CAT)
            case "$arg" in
                apps) apps_menu ;;
                docs) documents_menu ;;
                settings) settings_menu ;;
                shortcuts) shortcuts_menu ;;
                polyos_dev) polyos_dev_menu ;;
                reload) reload_menu ;;
                devices) devices_menu ;;
                config) config_manager_menu ;;
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
        SUBCAT)
            case "$arg" in
                reload) reload_menu ;;
                *) main_menu ;;
            esac
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
                poly-sync) trigger_zsh_func "poly-sync" ;;
                scan) trigger_zsh_func "dot-scan" ;;
                kill_gemini) kill_gemini_processes ;;
                fix_alt) clear; "$REPO_PATH/common/palette/fix-alt-keys.sh"; printf "Press Enter to return..."; read -r; main_menu ;;
                scan_device) scan_current_device ;;
                ssh_device) ssh_into_device ;;
                manual_device) manual_device_entry ;;
                exit) exit 0 ;;
            esac
            ;;
    esac
}
