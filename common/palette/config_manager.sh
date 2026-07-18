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

_ZELLIJ_THEME_DIR_WARNED=""

function check_zellij_theme_dir() {
    [[ -n "$_ZELLIJ_THEME_DIR_WARNED" ]] && return

    local current_theme_dir
    current_theme_dir=$(python3 "$KDL_SCRIPT" --get "$ZELLIJ_CONFIG" 2>/dev/null | \
        grep "^theme_dir|" | cut -d '|' -f 2)

    if [[ -n "$current_theme_dir" && "$current_theme_dir" != "$ZELLIJ_THEMES_DIR" ]]; then
        clear
        echo "󰅙  theme_dir is stale or points to a different location:"
        echo "   Current: $current_theme_dir"
        echo "   Expected: $ZELLIJ_THEMES_DIR"
        echo ""
        if confirm_action "Fix theme_dir to point to the expected path?"; then
            local result
            result=$(python3 "$KDL_SCRIPT" --set "$ZELLIJ_CONFIG" "theme_dir=$ZELLIJ_THEMES_DIR" 2>&1)
            echo "󰄬  $result"
            sleep 1
        else
            echo "  Skipped. You can edit theme_dir manually from the settings list."
            sleep 1
        fi
        _ZELLIJ_THEME_DIR_WARNED="yes"
    fi
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

    check_zellij_theme_dir

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

    list_items+="$((idx+1)) | 󰑐  Theme Colors...              | ${dim}Edit colors of installed themes${reset} | THEME_COLORS | theme_colors
"
    list_items+="$((idx+2)) | 󰅙  Back                         | ${dim}Return to config manager${reset} | ACTION | main_menu"

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
        THEME_COLORS) zellij_theme_colors_menu ;;
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
            if [[ "$key" == "theme_dir" ]]; then
                local suggested="$ZELLIJ_THEMES_DIR"
                echo "  Suggested: $suggested"
                echo "  (Press Enter to accept suggested value)"
                echo ""
                printf "  Enter new value: "
                read -r new_value
                if [[ -z "$new_value" ]]; then
                    new_value="$suggested"
                fi
            else
                printf "  Enter new value (leave empty to cancel): "
                read -r new_value
            fi

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

function _get_active_zellij_theme() {
    python3 "$KDL_SCRIPT" --get "$ZELLIJ_CONFIG" 2>/dev/null | grep "^theme|" | cut -d '|' -f 2
}

function zellij_theme_colors_menu() {
    local dim="\033[2m"
    local reset="\033[0m"
    local green="\033[32m"

    local active_theme
    active_theme=$(_get_active_zellij_theme)

    local items=""
    local idx=0
    while IFS= read -r theme_file; do
        ((idx++))
        local name
        name=$(basename "$theme_file" .kdl)
        local marker="  "
        [[ "$name" == "$active_theme" ]] && marker="${green}●${reset}"
        items+="$idx | $marker $name | ${dim}${theme_file}${reset} | PICK | $theme_file
"
    done < <(find "$ZELLIJ_THEMES_DIR" -maxdepth 1 -name '*.kdl' 2>/dev/null | sort)

    if [[ -z "$items" ]]; then
        clear
        echo "󰅙  No theme files found in $ZELLIJ_THEMES_DIR"
        sleep 2
        zellij_config_menu
        return
    fi

    items+="$((idx+1)) | 󰅙  Back | ${dim}Return to Zellij config manager${reset} | BACK | back"

    local selection=$(echo -e "$items" | fzf \
        --ansi \
        --height 100% \
        --reverse \
        --border rounded \
        --prompt "󰑐  " \
        --header "  Zellij Theme Colors  |  Active: $active_theme" \
        --delimiter ' \| ')

    [[ -z "$selection" ]] && zellij_config_menu && return

    local type arg
    type=$(echo "$selection" | awk -F' \\| ' '{print $4}' | xargs)
    arg=$(echo "$selection" | awk -F' \\| ' '{print $5}' | xargs)

    case "$type" in
        PICK)
            clear
            zellij_theme_color_editor "$arg"
            ;;
        BACK) zellij_config_menu ;;
    esac
}

function zellij_theme_color_editor() {
    local theme_file="$1"
    local theme_name
    theme_name=$(basename "$theme_file" .kdl)

    local tmp_file
    tmp_file=$(mktemp)
    cp "$theme_file" "$tmp_file"

    local colors_data
    colors_data=$(python3 "$KDL_SCRIPT" --get-theme-colors "$tmp_file" 2>/dev/null)

    if [[ -z "$colors_data" ]]; then
        echo "󰅙  Could not read colors from theme file."
        sleep 2
        rm -f "$tmp_file"
        zellij_theme_colors_menu
        return
    fi

    local zellij_color_keys=(black red green yellow blue magenta cyan white orange bg fg)
    local -A color_map

    while IFS='|' read -r key value; do
        color_map["$key"]="$value"
    done <<< "$colors_data"

    while true; do
        clear
        local dim="\033[2m"
        local reset="\033[0m"

        local items=""
        local idx=0
        for key in "${zellij_color_keys[@]}"; do
            ((idx++))
            local val="${color_map[$key]:---}"
            local padded_key=$(printf "%-10s" "$key")
            items+="$idx | 󰴄  ${padded_key} ${val} | ${dim}Edit color${reset} | EDIT | $key|$val
"
        done

        items+="$((idx+1)) | 󰄬  Save theme               | ${dim}Save changes and apply${reset} | SAVE | save
"
        items+="$((idx+2)) | 󰅙  Cancel                    | ${dim}Discard changes${reset} | CANCEL | cancel"

        local selection=$(echo -e "$items" | fzf \
            --ansi \
            --height 100% \
            --reverse \
            --border rounded \
            --prompt "󰅳  " \
            --header "  Zellij Theme Colors  |  $theme_name" \
            --delimiter ' \| ')

        [[ -z "$selection" ]] && { rm -f "$tmp_file"; zellij_theme_colors_menu; return; }

        local type arg
        type=$(echo "$selection" | awk -F' \\| ' '{print $4}' | xargs)
        arg=$(echo "$selection" | awk -F' \\| ' '{print $5}' | xargs)

        case "$type" in
            EDIT)
                local color_key=$(echo "$arg" | cut -d'|' -f1)
                local current_val=$(echo "$arg" | cut -d'|' -f2)
                clear
                echo "󰅳  Edit $color_key"
                echo "──────────────────────────────"
                echo "  Current value: $current_val"
                echo ""
                echo "  Type 'default' or 'reset' to restore original value."
                printf "  Enter new hex color (e.g. #ff0000) or Enter to keep: "
                read -r new_val

                if [[ -z "$new_val" ]]; then
                    continue
                fi

                if [[ "$new_val" == "default" || "$new_val" == "reset" ]]; then
                    local orig_val
                    orig_val=$(python3 "$KDL_SCRIPT" --get-theme-colors "$theme_file" 2>/dev/null | \
                        grep "^$color_key|" | cut -d '|' -f 2)
                    if [[ -n "$orig_val" ]]; then
                        new_val="$orig_val"
                    else
                        echo "  No original value found. Keeping current."
                        sleep 1
                        continue
                    fi
                elif ! validate_hex "$new_val"; then
                    echo "  Invalid hex color. Use format #rrggbb"
                    sleep 2
                    continue
                fi

                local result
                result=$(python3 "$KDL_SCRIPT" --set-theme-color "$tmp_file" "$color_key=$new_val" 2>&1)
                if [[ $? -eq 0 ]]; then
                    color_map["$color_key"]="$new_val"
                    echo "󰄬  $result"
                    sleep 1
                else
                    echo "󰅙  $result"
                    sleep 2
                fi
                ;;

            SAVE)
                cp "$tmp_file" "$theme_file"
                rm -f "$tmp_file"
                clear
                echo "󰄬  Theme '$theme_name' colors saved to $theme_file"
                sleep 1
                trigger_zsh_func "dot-zellij-reload"
                return
                ;;

            CANCEL)
                rm -f "$tmp_file"
                zellij_theme_colors_menu
                return
                ;;
        esac
    done
}
