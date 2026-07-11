#!/bin/bash

# ==========================================
# 󰒓  CONFIGURATION MANAGER
# ==========================================

ZELLIJ_CONFIG="${REPO_PATH}/common/config/zellij/config.kdl"
ZELLIJ_THEMES_DIR="${REPO_PATH}/common/config/zellij/themes"
KDL_SCRIPT="${PALETTE_LIB}/kdl_config.py"

function config_manager_menu() {
    local dim="\033[2m"
    local reset="\033[0m"

    local list_items=""
    list_items+="1 | 󰅳  Zellij... | ${dim}Configure Zellij terminal multiplexer${reset} | CAT | zellij
"
    list_items+="2 | 󰅙  Back | ${dim}Return to main menu${reset} | ACTION | main_menu"

    local selection=$(echo -e "$list_items" | fzf \
        --ansi \
        --height 100% \
        --reverse \
        --border rounded \
        --prompt "󰒓  " \
        --header "Configuration Manager" \
        --delimiter ' \| ')

    if [[ -z "$selection" ]]; then main_menu; return; fi

    local type arg
    type=$(echo "$selection" | awk -F' \\| ' '{print $4}' | xargs)
    arg=$(echo "$selection" | awk -F' \\| ' '{print $5}' | xargs)

    case "$type" in
        CAT)
            case "$arg" in
                zellij) zellij_config_menu ;;
            esac
            ;;
        ACTION) main_menu ;;
    esac
}

function zellij_config_menu() {
    local dim="\033[2m"
    local reset="\033[0m"

    if [[ ! -f "$ZELLIJ_CONFIG" ]]; then
        clear
        echo "󰅙  Zellij config not found at:"
        echo "   $ZELLIJ_CONFIG"
        sleep 2
        config_manager_menu
        return
    fi

    if [[ ! -f "$KDL_SCRIPT" ]]; then
        clear
        echo "󰅙  kdl_config.py not found at:"
        echo "   $KDL_SCRIPT"
        sleep 2
        config_manager_menu
        return
    fi

    local settings_data
    settings_data=$(python3 "$KDL_SCRIPT" --get "$ZELLIJ_CONFIG" 2>/dev/null)

    if [[ -z "$settings_data" ]]; then
        clear
        echo "󰅙  No settings found in config file (or parse error)."
        sleep 2
        config_manager_menu
        return
    fi

    local list_items=""
    local idx=0

    while IFS='|' read -r key value stype desc hint choices; do
        ((idx++))
        local display_value="$value"
        [[ ${#display_value} -gt 12 ]] && display_value="${display_value:0:9}..."
        local padded_key=$(printf "%-22s" "$key")
        local padded_value=$(printf "%-12s" "$display_value")
        list_items+="$idx | 󰇒  ${padded_key} ${padded_value} | ${dim}$desc${reset} | SETTING | $key|$stype|$hint|$choices
"
    done <<< "$settings_data"

    list_items+="$((idx+1)) | 󰅙  Back                         | ${dim}Return to config manager${reset} | ACTION | main_menu"

    local selection=$(echo -e "$list_items" | fzf \
        --ansi \
        --height 100% \
        --reverse \
        --border rounded \
        --prompt "󰅳  " \
        --header "  Zellij Configuration Manager  |  $(basename "$ZELLIJ_CONFIG")" \
        --delimiter ' \| ' \
        --with-nth '1,2,3' \
        --preview '
            k=$(echo {5} | cut -d"|" -f1)
            t=$(echo {5} | cut -d"|" -f2)
            h=$(echo {5} | cut -d"|" -f3)
            c=$(echo {5} | cut -d"|" -f4)
            echo "────────────────────────────────────"
            echo "  Setting:  $k"
            echo "  Current:  $(echo {2} | xargs)"
            echo "  Type:     $t"
            echo "────────────────────────────────────"
            echo "  $h"
            if [ -n "$c" ]; then
                echo "  Options:  $(echo "$c" | tr "," "  ")"
            fi
        ')

    if [[ -z "$selection" ]]; then config_manager_menu; return; fi

    local type arg
    type=$(echo "$selection" | awk -F' \\| ' '{print $4}' | xargs)
    arg=$(echo "$selection" | awk -F' \\| ' '{print $5}' | xargs)

    case "$type" in
        SETTING)
            local setting_key=$(echo "$arg" | cut -d '|' -f 1 | xargs)
            local setting_type=$(echo "$arg" | cut -d '|' -f 2 | xargs)
            local setting_hint=$(echo "$arg" | cut -d '|' -f 3 | xargs)
            local setting_choices=$(echo "$arg" | cut -d '|' -f 4 | xargs)
            edit_zellij_setting "$setting_key" "$setting_type" "$setting_hint" "$setting_choices"
            ;;
        ACTION) config_manager_menu ;;
    esac
}

function edit_zellij_setting() {
    local key="$1"
    local stype="$2"
    local hint="$3"
    local choices="$4"
    local new_value=""

    # Get current value from config
    local current_value
    current_value=$(python3 "$KDL_SCRIPT" --get "$ZELLIJ_CONFIG" 2>/dev/null | \
        grep "^$key|" | cut -d '|' -f 2)

    if [[ -z "$current_value" ]]; then
        clear
        echo "󰅙  Could not read current value for '$key'."
        sleep 2
        zellij_config_menu
        return
    fi

    case "$stype" in
        bool)
            local selected
            selected=$(echo -e "true\nfalse" | fzf \
                --ansi \
                --height 30% \
                --reverse \
                --border rounded \
                --prompt "󰇒  " \
                --header "  $key  |  $hint" \
                --preview 'echo "Current: '"$current_value"'"')

            if [[ -z "$selected" ]]; then
                zellij_config_menu
                return
            fi
            new_value="$selected"
            ;;

        choice)
            local choice_list
            if [[ -n "$choices" ]]; then
                choice_list=$(echo "$choices" | tr ',' '\n')
            fi

            local selected
            selected=$(echo -e "$choice_list" | fzf \
                --ansi \
                --height 40% \
                --reverse \
                --border rounded \
                --prompt "󰇒  " \
                --header "  $key  |  $hint" \
                --preview 'echo "Current: '"$current_value"'"')

            if [[ -z "$selected" ]]; then
                zellij_config_menu
                return
            fi
            new_value="$selected"
            ;;

        string)
            clear
            echo "󰇒  $key"
            echo "────────────────────────────────────────"
            echo "  $hint"
            echo ""
            echo "  Current value: $current_value"
            echo ""
            printf "  Enter new value (leave empty to cancel): "
            read -r new_value

            if [[ -z "$new_value" ]]; then
                echo ""
                printf "Press Enter to return..."
                read -r
                zellij_config_menu
                return
            fi
            ;;

        *)
            clear
            echo "󰅙  Unknown setting type '$stype' for '$key'."
            sleep 2
            zellij_config_menu
            return
            ;;
    esac

    # Save the change
    clear
    local result
    result=$(python3 "$KDL_SCRIPT" --set "$ZELLIJ_CONFIG" "$key=$new_value" 2>&1)

    if [[ $? -eq 0 ]]; then
        echo "󰄬  $result"
    else
        echo "󰅙  $result"
    fi

    echo ""
    printf "Press Enter to return..."
    read -r
    zellij_config_menu
}
