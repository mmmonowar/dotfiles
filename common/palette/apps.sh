#!/bin/bash

# ==========================================
# 📦  PACKAGE MANAGEMENT
# ==========================================

function get_app_description() {
    local app_name="$1"
    # 1. Check if we already have it in the meta file
    if [[ -f "$META_PATH" ]]; then
        local desc=$(grep "^${app_name}|" "$META_PATH" | cut -d'|' -f2-)
        if [[ -n "$desc" ]]; then
            echo "$desc"
            return
        fi
    fi

    # 2. If not found, fetch it dynamically from brew
    local brew_desc=$(brew info "$app_name" 2>/dev/null | head -n 2 | tail -n 1 | xargs)
    
    # 3. If brew returned a valid description
    if [[ -n "$brew_desc" && ! "$brew_desc" =~ "==>" ]]; then
        # Cache it for next time
        echo "${app_name}|${brew_desc}" >> "$META_PATH"
        echo "$brew_desc"
    else
        echo "󰒓  CLI Tool"
    fi
}

function install_app() {
    clear
    echo "󰏔  Install App (via Homebrew)"
    echo "-----------------------------"
    echo "This will install the app and automatically update your Brewfile and GitHub repo."
    printf "Enter package name (or press Enter to cancel): "
    read -r app_name
    
    if [[ -z "$app_name" ]]; then
        main_menu
        return
    fi
    
    trigger_and_sync "brew install --verbose $app_name"
}

function uninstall_app() {
    if [[ ! -f "$BREWFILE_PATH" ]]; then
        echo "󰅙  Brewfile not found at $BREWFILE_PATH!"
        sleep 2
        main_menu
        return
    fi

    local apps=()
    while IFS= read -r line; do
        apps+=("$line")
    done < <(grep '^brew "' "$BREWFILE_PATH" | cut -d '"' -f 2)
    
    local list_items=""
    local idx=1
    for app in "${apps[@]}"; do
        list_items+="$idx | $app
"
        ((idx++))
    done

    local selection
    selection=$(echo -e "$list_items" | fzf 
        --height 100% 
        --reverse 
        --border rounded 
        --prompt "󰆴  " 
        --header "Select App to Uninstall")

    if [[ -n "$selection" ]]; then
        local app_name=$(echo "$selection" | cut -d '|' -f 2 | xargs)
        clear
        if confirm_action "Uninstall $app_name and sync to GitHub?"; then
            if [[ "$OS_ENV" == "mac" ]]; then
                sed -i '' "/^$app_name|/d" "$META_PATH" 2>/dev/null
            else
                sed -i "/^$app_name|/d" "$META_PATH" 2>/dev/null
            fi
            trigger_and_sync "brew uninstall --verbose $app_name"
        else
            uninstall_app
        fi
    else
        main_menu
    fi
}

function apps_menu() {
    local query=$1
    if [[ ! -f "$BREWFILE_PATH" ]]; then
        echo -e "󰅙  Brewfile missing at:
$BREWFILE_PATH"
        sleep 2
        main_menu
        return
    fi

    local apps=()
    while IFS= read -r line; do
        apps+=("$line")
    done < <(grep '^brew "' "$BREWFILE_PATH" | cut -d '"' -f 2)
    
    local missing_apps=()
    for app in "${apps[@]}"; do
        if ! grep -q "^${app}|" "$META_PATH" 2>/dev/null; then
            missing_apps+=("$app")
        fi
    done

    if [[ ${#missing_apps[@]} -gt 0 ]]; then
        echo "󰇥  Fetching new app descriptions..."
        for app in "${missing_apps[@]}"; do
            get_app_description "$app" > /dev/null
        done
    fi

    local list_items=$(awk -F'|' '
        NR==FNR { cache[$1]=$2; next }
        { 
            idx++
            desc = cache[$1] ? cache[$1] : "󰒓  CLI Tool"
            print idx " | " $1 " | \033[2m" desc "\033[0m"
        }
    ' "$META_PATH" <(printf "%s
" "${apps[@]}"))

    local selection=$(echo -e "$list_items" | fzf 
        --ansi 
        --height 100% 
        --reverse 
        --border rounded 
        --prompt "󱐋  " 
        --query "$query" 
        --header "Select App (Type index or name)" 
        --delimiter ' \| ' 
        --with-nth 1,2,3)

    if [[ -n "$selection" ]]; then
        local selected_app=$(echo "$selection" | cut -d '|' -f 2 | xargs)
        trigger_zsh_func "$selected_app"
    else
        main_menu
    fi
}
