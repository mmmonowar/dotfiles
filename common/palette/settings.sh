#!/bin/bash

# ==========================================
# 🚀  SETTINGS LOGIC
# ==========================================

function open_scratchpad() {
    local path_var="POLYTERM_SCRATCHPAD_$OS_ENV_UPPER"
    local path="${!path_var}"
    
    # Fallback to general linux only if the current OS path is unset (not empty string)
    if [[ -z "$path" && "${!path_var+v}" != "v" ]]; then
        path="$POLYTERM_SCRATCHPAD_LINUX"
    fi
    
    if [[ -n "$path" && -f "$path" ]]; then
        trigger_zsh_func "micro \"$path\""
    elif [[ -n "$path" ]]; then
        if confirm_action "File does not exist. Create it at $path?"; then
            mkdir -p "$(dirname "$path")"
            touch "$path"
            trigger_zsh_func "micro \"$path\""
        else
            scratchpad_menu
        fi
    else
        echo "󰅙  Scratchpad is disabled or not configured for this device ($OS_ENV)."
        sleep 2
        scratchpad_menu
    fi
}

function update_scratchpad_path() {
    local os=$1
    local os_upper=$(echo "$os" | tr '[:lower:]' '[:upper:]')
    local key="POLYTERM_SCRATCHPAD_$os_upper"
    local current_val="${!key}"
    
    clear
    echo "󰒓  Update Scratchpad Path ($os)"
    echo "-----------------------------"
    echo "Current: ${current_val:-[NOT SET]}"
    echo ""
    echo "Tips:"
    echo " - Enter a new absolute path to update."
    echo " - Type 'clear' or 'none' to disable scratchpad for this device."
    echo " - Press Enter to keep the current value."
    echo ""
    
    local default_suggestion="\$HOME/GitHub/mmmonowar/log-captures/10 Worklogs/scratch-pad.md"
    
    echo "Default Suggestion:"
    echo "$default_suggestion"
    echo ""
    printf "Enter new path (or Enter to keep current): "
    read -r new_path
    
    if [[ "$new_path" == "clear" || "$new_path" == "none" ]]; then
        update_setting "$key" ""
        echo "󰄬  Scratchpad disabled for $os."
        sleep 1
    elif [[ -n "$new_path" ]]; then
        # If user pasted a path with their literal home, update_setting will sanitize it
        update_setting "$key" "$new_path"
        echo "󰄬  Path updated."
        sleep 1
    fi
    scratchpad_menu
}

function scratchpad_menu() {
    # Refresh settings
    [[ -f "$SETTINGS_FILE" ]] && source "$SETTINGS_FILE"

    local query=$1
    local dim="\033[2m"
    local reset="\033[0m"
    
    local linux_mark=""; [[ "$OS_ENV" == "linux" ]] && linux_mark=" (Current)"
    local wsl_mark=""; [[ "$OS_ENV" == "wsl" ]] && wsl_mark=" (Current)"
    local mac_mark=""; [[ "$OS_ENV" == "mac" ]] && mac_mark=" (Current)"
    
    local options="1 | 󰒓  Set Path (Linux)$linux_mark | ${dim}$(truncate_desc "$POLYTERM_SCRATCHPAD_LINUX")${reset} | SET_LINUX\n"
    options+="2 | 󰒓  Set Path (WSL)$wsl_mark | ${dim}$(truncate_desc "$POLYTERM_SCRATCHPAD_WSL")${reset} | SET_WSL\n"
    options+="3 | 󰒓  Set Path (Mac)$mac_mark | ${dim}$(truncate_desc "$POLYTERM_SCRATCHPAD_MAC")${reset} | SET_MAC"

    local selection=$(echo -e "$options" | fzf \
        --ansi \
        --height 100% \
        --reverse \
        --border rounded \
        --prompt "󰈙  " \
        --query "$query" \
        --header "Scratchpad Configuration" \
        --delimiter ' \| ')

    if [[ -n "$selection" ]]; then
        local choice=$(echo "$selection" | cut -d '|' -f 4 | xargs)
        case "$choice" in
            SET_LINUX) update_scratchpad_path "linux" ;;
            SET_WSL) update_scratchpad_path "wsl" ;;
            SET_MAC) update_scratchpad_path "mac" ;;
        esac
    else
        main_menu
    fi
}

function settings_menu() {
    # Refresh settings
    [[ -f "$SETTINGS_FILE" ]] && source "$SETTINGS_FILE"
    
    local query=$1
    local dim="\033[2m"
    local reset="\033[0m"
    
    local scan_push_status="[OFF]"
    [[ "$POLYTERM_SCAN_ON_PUSH" == "true" ]] && scan_push_status="[ON]"
    
    local scan_pull_status="[OFF]"
    [[ "$POLYTERM_SCAN_ON_PULL" == "true" ]] && scan_pull_status="[ON]"

    local settings_options="1 | 󰒃  Security Check on Push $scan_push_status | ${dim}Toggle pre-push scan${reset} | SCAN_PUSH\n"
    settings_options+="2 | 󰒃  Security Check on Pull $scan_pull_status | ${dim}Toggle post-pull scan${reset} | SCAN_PULL\n"
    settings_options+="3 | 󰈙  Scratchpad Settings... | ${dim}Configure paths and access${reset} | SCRATCHPAD"

    local selection=$(echo -e "$settings_options" | fzf \
        --ansi \
        --height 100% \
        --reverse \
        --border rounded \
        --prompt "󰒓  " \
        --query "$query" \
        --header "Select Setting (Type index or name)" \
        --delimiter ' \| ')

    if [[ -n "$selection" ]]; then
        local choice=$(echo "$selection" | cut -d '|' -f 4 | xargs)
        case "$choice" in
            SCAN_PUSH)
                update_setting "POLYTERM_SCAN_ON_PUSH" "$([[ "$POLYTERM_SCAN_ON_PUSH" == "true" ]] && echo false || echo true)"
                settings_menu
                ;;
            SCAN_PULL)
                update_setting "POLYTERM_SCAN_ON_PULL" "$([[ "$POLYTERM_SCAN_ON_PULL" == "true" ]] && echo false || echo true)"
                settings_menu
                ;;
            SCRATCHPAD) scratchpad_menu ;;
        esac
    else
        main_menu
    fi
}
