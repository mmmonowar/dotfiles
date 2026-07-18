#!/bin/bash

# ==========================================
# 📦  PACKAGE MANAGEMENT
# ==========================================

function get_app_description() {
    local app_name="$1"
    local app_type="$2"
    # 1. Check if we already have it in the meta file
    if [[ -f "$META_PATH" ]]; then
        local desc=$(grep "^${app_name}|" "$META_PATH" | cut -d'|' -f2-)
        if [[ -n "$desc" ]]; then
            echo "$desc"
            return
        fi
    fi

    # 2. If not found, fetch it dynamically from brew
    local brew_desc
    if [[ "$app_type" == "cask" ]]; then
        brew_desc=$(brew info --cask "$app_name" 2>/dev/null | head -n 2 | tail -n 1 | xargs)
    else
        brew_desc=$(brew info "$app_name" 2>/dev/null | head -n 2 | tail -n 1 | xargs)
    fi
    
    # 3. If brew returned a valid description
    if [[ -n "$brew_desc" && ! "$brew_desc" =~ "==>" ]]; then
        # Cache it for next time
        echo "${app_name}|${brew_desc}" >> "$META_PATH"
        echo "$brew_desc"
    else
        if [[ "$app_type" == "cask" ]]; then
            echo "󰀵  Cask Application"
        else
            echo "󰒓  CLI Tool"
        fi
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
    done < <(grep -E '^(brew|cask) "' "$BREWFILE_PATH" | sed -E 's/^(brew|cask) "([^"]+)".*/\1: \2/')
    
    local list_items=""
    local idx=1
    for app in "${apps[@]}"; do
        list_items+="$(printf "%3s │ %-35s │ %b │ %-8s │ %s\n" "$idx" "$app" "\033[2mSelect to uninstall\033[0m" "APP" "$app")"
        ((idx++))
    done

    local selection
    selection=$(echo -e "$list_items" | fzf \
        --ansi \
        --height 100% \
        --reverse \
        --border rounded \
        --prompt "󰆴  " \
        --header "Select App to Uninstall" \
        --delimiter ' │ ' \
        --with-nth '1,2,3')

    if [[ -n "$selection" ]]; then
        local selected_item=$(echo "$selection" | awk -F'│' '{print $2}' | xargs)
        local type=$(echo "$selected_item" | cut -d ':' -f 1 | xargs)
        local app_name=$(echo "$selected_item" | cut -d ':' -f 2 | xargs)
        clear
        if confirm_action "Uninstall $app_name ($type) and sync to GitHub?"; then
            if [[ "$OS_ENV" == "mac" ]]; then
                sed -i '' "/^$app_name|/d" "$META_PATH" 2>/dev/null
            else
                sed -i "/^$app_name|/d" "$META_PATH" 2>/dev/null
            fi
            
            if [[ "$type" == "cask" ]]; then
                trigger_and_sync "brew uninstall --cask --verbose $app_name"
            else
                trigger_and_sync "brew uninstall --verbose $app_name"
            fi
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
        echo -e "󰅙  Brewfile missing at:\n$BREWFILE_PATH"
        sleep 2
        main_menu
        return
    fi

    local apps=()
    while IFS= read -r line; do
        apps+=("$line")
    done < <(grep -E '^(brew|cask) "' "$BREWFILE_PATH" | sed -E 's/^(brew|cask) "([^"]+)".*/\1: \2/')
    
    local missing_apps=()
    local missing_types=()
    for app in "${apps[@]}"; do
        local type=$(echo "$app" | cut -d ':' -f 1 | xargs)
        local name=$(echo "$app" | cut -d ':' -f 2 | xargs)
        if ! grep -q "^${name}|" "$META_PATH" 2>/dev/null; then
            missing_apps+=("$name")
            missing_types+=("$type")
        fi
    done

    if [[ ${#missing_apps[@]} -gt 0 ]]; then
        echo "󰇥  Fetching new app descriptions..."
        local i
        for ((i=0; i<${#missing_apps[@]}; i++)); do
            get_app_description "${missing_apps[$i]}" "${missing_types[$i]}" > /dev/null
        done
    fi

    local list_items=$(awk -F'|' '
        NR==FNR { cache[$1]=$2; next }
        { 
            idx++
            split($1, parts, ": ")
            type = parts[1]
            name = parts[2]
            desc = cache[name] ? cache[name] : (type == "cask" ? "󰀵  Cask Application" : "󰒓  CLI Tool")
            printf "%3s │ %-35s │ \033[2m%s\033[0m │ %-8s │ %s\n", idx, name, desc, type, name
        }
    ' "$META_PATH" <(printf "%s\n" "${apps[@]}"))

    local selection=$(echo -e "$list_items" | fzf \
        --ansi \
        --height 100% \
        --reverse \
        --border rounded \
        --prompt "󱐋  " \
        --query "$query" \
        --header "Select App (Type index or name)" \
        --delimiter ' │ ' \
        --with-nth '1,2,3')

    if [[ -n "$selection" ]]; then
        local selected_app=$(echo "$selection" | awk -F'│' '{print $2}' | xargs)
        
        # Determine if it's a cask to run with open -a on macOS
        local is_cask=false
        for app in "${apps[@]}"; do
            if [[ "$app" == "cask: $selected_app" ]]; then
                is_cask=true
                break
            fi
        done
        
        local launch_cmd
        launch_cmd=$(resolve_command "$selected_app")

        if [ "$is_cask" = true ]; then
            if [[ "$OS_ENV" == "mac" ]]; then
                trigger_zsh_func "open -a '$selected_app'"
            else
                trigger_zsh_func "$launch_cmd &"
            fi
        else
            trigger_zsh_func "$launch_cmd"
        fi
    else
        main_menu
    fi
}
