#!/bin/bash

# ==========================================
# 🚀  SETTINGS LOGIC
# ==========================================

function open_scratchpad() {
    local device_id=$(hostname | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9_-]//g')
    local path="${DOTFILES_DATA}/scratchpad/${device_id}/scratch-pad.md"
    
    if [[ -f "$path" ]]; then
        trigger_zsh_func "micro \"$path\""
    else
        if confirm_action "Scratchpad does not exist. Create it at $path?"; then
            mkdir -p "$(dirname "$path")"
            touch "$path"
            trigger_zsh_func "micro \"$path\""
        fi
    fi
}

function scratchpad_menu() {
    local device_id=$(hostname | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9_-]//g')
    local path="${DOTFILES_DATA}/scratchpad/${device_id}/scratch-pad.md"
    local dim="\033[2m"
    local reset="\033[0m"
    
    local options="$(printf "%3s │ %-35s │ %b │ %-8s │ %s\n" "1" "󰈙  Open Scratchpad" "${dim}${path}${reset}" "ACTION" "OPEN")"

    local selection=$(echo -e "$options" | fzf \
        --ansi \
        --height 100% \
        --reverse \
        --border rounded \
        --prompt "󰈙  " \
        --header "Scratchpad (${device_id})" \
        --delimiter ' │ ' \
        --with-nth '1,2,3')

    if [[ -n "$selection" ]]; then
        local choice=$(echo "$selection" | awk -F'│' '{print $4}' | xargs)
        case "$choice" in
            OPEN) open_scratchpad ;;
        esac
    else
        main_menu
    fi
}

function theme_color_editor() {
    local theme_file="$1"
    local theme_name="$2"

    local base_file="$POLYTERM_USER_THEMES_DIR/$theme_name.json"
    [[ ! -f "$base_file" ]] && base_file="$POLYTERM_THEMES_DIR/$theme_name.json"
    [[ ! -f "$base_file" ]] && base_file=""

    while true; do
        clear
        local dim="\033[2m"
        local reset="\033[0m"
        local cyan="\033[36m"
        local current_name=$(get_theme_display_name "$theme_name")

        local items=""
        local idx=0
        local color_keys=(background foreground black red green yellow blue purple cyan white brightBlack brightRed brightGreen brightYellow brightBlue brightPurple brightCyan brightWhite)

        for key in "${color_keys[@]}"; do
            ((idx++))
            local val
            val=$(python3 -c "import json,sys;print(json.load(open(sys.argv[1])).get('colors',{}).get(sys.argv[2],''))" "$theme_file" "$key" 2>/dev/null)
            local padded_key=$(printf "%-18s" "$key")
            items+="$(printf "%3s │ %-35s │ %b │ %-8s │ %s\n" "$idx" "󰴄  ${padded_key} ${val}" "${dim}Click to edit color${reset}" "EDIT" "$key|$val")"
        done

        items+="$(printf "%3s │ %-35s │ %b │ %-8s │ %s\n" "$((idx+1))" "󰄬  Save theme" "${dim}Save as new custom theme${reset}" "SAVE" "save")"
        items+="$(printf "%3s │ %-35s │ %b │ %-8s │ %s\n" "$((idx+2))" "󰅙  Cancel" "${dim}Discard changes${reset}" "CANCEL" "cancel")"

        local selection=$(echo -e "$items" | fzf \
            --ansi \
            --height 100% \
            --reverse \
            --border rounded \
            --prompt "󰑐  " \
            --header "  Color Editor  |  $current_name" \
            --delimiter ' │ ' \
            --with-nth '1,2,3' \
            --preview '
                k=$(echo {5} | cut -d"|" -f1)
                v=$(echo {5} | cut -d"|" -f2)
                echo "────────────────────────────────────"
                echo "  Color:  $k"
                echo "  Value:  $v"
            ')

        [[ -z "$selection" ]] && return 1

        local type arg
        type=$(echo "$selection" | awk -F' │ ' '{print $4}' | xargs)
        arg=$(echo "$selection" | awk -F' │ ' '{print $5}' | xargs)

        case "$type" in
            EDIT)
                local color_key=$(echo "$arg" | cut -d'|' -f1)
                local current_val=$(echo "$arg" | cut -d'|' -f2)
                clear
                echo "󰑐  Edit $color_key"
                echo "────────────────────────────"
                echo "  Current value: $current_val"
                echo ""
                echo "  Type 'default' or 'reset' to restore original value."
                printf "  Enter new hex color (e.g. #ff0000) or Enter to keep: "
                read -r new_val

                if [[ -z "$new_val" ]]; then
                    continue
                fi

                if [[ "$new_val" == "default" || "$new_val" == "reset" ]]; then
                    if [[ -n "$base_file" ]]; then
                        local orig_val
                        orig_val=$(python3 -c "import json,sys;print(json.load(open(sys.argv[1])).get('colors',{}).get(sys.argv[2],''))" "$base_file" "$color_key" 2>/dev/null)
                        if [[ -n "$orig_val" ]]; then
                            new_val="$orig_val"
                        else
                            echo "  No original value found for $color_key. Keeping current."
                            sleep 1
                            continue
                        fi
                    else
                        echo "  No base theme file found. Keeping current."
                        sleep 1
                        continue
                    fi
                elif ! validate_hex "$new_val"; then
                    echo "  Invalid hex color. Use format #rrggbb"
                    sleep 2
                    continue
                fi

                python3 -c "
import json, sys
d = json.load(open(sys.argv[1]))
d.setdefault('colors', {})[sys.argv[2]] = sys.argv[3]
d.setdefault('fzf', {}).pop(sys.argv[2], None)
json.dump(d, open(sys.argv[1], 'w'), indent=2)
" "$theme_file" "$color_key" "$new_val"
                echo "󰄬  $color_key updated to $new_val"
                sleep 1
                ;;

            SAVE)
                clear
                printf "Enter name for custom theme: "
                read -r custom_name
                if [[ -z "$custom_name" ]]; then
                    echo "Cancelled."
                    sleep 1
                    continue
                fi
                local slug=$(echo "$custom_name" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9_-]/-/g' | sed 's/--*/-/g')
                local out_file="$POLYTERM_USER_THEMES_DIR/$slug.json"
                python3 -c "
import json, sys
d = json.load(open(sys.argv[1]))
d['name'] = sys.argv[2]
json.dump(d, open(sys.argv[3], 'w'), indent=2)
" "$theme_file" "$custom_name" "$out_file"
                echo "󰄬  Theme '$custom_name' saved!"
                sleep 1
                update_setting "POLYTERM_THEME" "$slug"
                load_theme "$slug"
                return 0
                ;;

            CANCEL)
                return 1
                ;;
        esac
    done
}

function customize_theme_menu() {
    clear
    local dim="\033[2m"
    local reset="\033[0m"

    local items=""
    local idx=0
    while IFS= read -r theme; do
        ((idx++))
        local display_name=$(get_theme_display_name "$theme")
        local src="built-in"
        [[ -f "$POLYTERM_USER_THEMES_DIR/$theme.json" ]] && src="custom"
        items+="$(printf "%3s │ %-35s │ %b │ %-8s │ %s\n" "$idx" "󰑐  $display_name" "${dim}${src}${reset}" "PICK" "$theme")"
        if [[ -f "$POLYTERM_THEMES_DIR/$theme.json" && -f "$POLYTERM_USER_THEMES_DIR/$theme.json" ]]; then
            ((idx++))
            items+="$(printf "%3s │ %-35s │ %b │ %-8s │ %s\n" "$idx" "󰑐  $display_name (built-in)" "${dim}built-in${reset}" "PICK" ":builtin:$theme")"
        fi
    done < <(list_themes)

    items+="$(printf "%3s │ %-35s │ %b │ %-8s │ %s\n" "$((idx+1))" "󰅙  Back" "${dim}Return to theme menu${reset}" "BACK" "back")"

    local selection=$(echo -e "$items" | fzf \
        --ansi \
        --height 100% \
        --reverse \
        --border rounded \
        --prompt "󰑐  " \
        --header "  Pick a base theme to customize" \
        --delimiter ' │ ' \
        --with-nth '1,2,3')

    [[ -z "$selection" ]] && theme_menu && return

    local type arg
        type=$(echo "$selection" | awk -F' │ ' '{print $4}' | xargs)
        arg=$(echo "$selection" | awk -F' │ ' '{print $5}' | xargs)

    case "$type" in
        PICK)
            local tmp_file=$(mktemp)
            local base_name="$arg"
            base_name="${base_name#:builtin:}"
            base_name="${base_name#:custom:}"
            local src_file=""
            if [[ "$arg" == :builtin:* ]]; then
                src_file="$POLYTERM_THEMES_DIR/$base_name.json"
            elif [[ "$arg" == :custom:* ]]; then
                src_file="$POLYTERM_USER_THEMES_DIR/$base_name.json"
            else
                src_file="$POLYTERM_USER_THEMES_DIR/$base_name.json"
                [[ ! -f "$src_file" ]] && src_file="$POLYTERM_THEMES_DIR/$base_name.json"
            fi
            python3 -c "
import json, sys
d = json.load(open(sys.argv[1]))
out = {'name': d.get('name', sys.argv[2]), 'colors': d.get('colors', {}), 'fzf': d.get('fzf', {})}
json.dump(out, open(sys.argv[3], 'w'), indent=2)
" "$src_file" "$base_name" "$tmp_file"

            theme_color_editor "$tmp_file" "$base_name"
            rm -f "$tmp_file"
            theme_menu
            ;;
        BACK) theme_menu ;;
    esac
}

function theme_menu() {
    # Refresh settings
    [[ -f "$SETTINGS_FILE" ]] && source "$SETTINGS_FILE"

    local dim="\033[2m"
    local reset="\033[0m"
    local green="\033[32m"

    while true; do
        local items=""
        local idx=0

        while IFS= read -r theme; do
            ((idx++))
            local display_name=$(get_theme_display_name "$theme")
            local marker="  "
            local src="built-in"
            [[ -f "$POLYTERM_USER_THEMES_DIR/$theme.json" ]] && src="custom"
            if [[ "$theme" == "$POLYTERM_THEME" ]]; then
                marker="${green}●${reset}"
            fi
            items+="$(printf "%3s │ %-35s │ %b │ %-8s │ %s\n" "$idx" "$marker $display_name" "${dim}${src}${reset}" "SELECT" "$theme")"
            if [[ -f "$POLYTERM_THEMES_DIR/$theme.json" && -f "$POLYTERM_USER_THEMES_DIR/$theme.json" ]]; then
                ((idx++))
                local bm="  "
                [[ ":builtin:$theme" == "$POLYTERM_THEME" ]] && bm="${green}●${reset}"
                items+="$(printf "%3s │ %-35s │ %b │ %-8s │ %s\n" "$idx" "$bm $display_name (built-in)" "${dim}built-in${reset}" "SELECT" ":builtin:$theme")"
            fi
        done < <(list_themes)

        items+="$(printf "%3s │ %-35s │ %b │ %-8s │ %s\n" "$((idx+1))" "󰑐  Customize theme..." "${dim}Create or edit a custom theme${reset}" "CUSTOMIZE" "customize")"
        items+="$(printf "%3s │ %-35s │ %b │ %-8s │ %s\n" "$((idx+2))" "󰅙  Back" "${dim}Return to settings menu${reset}" "BACK" "back")"

        local selection=$(echo -e "$items" | fzf \
            --ansi \
            --height 100% \
            --reverse \
            --border rounded \
            --prompt "󰑐  " \
            --header "  Select Theme  |  Current: $(get_theme_display_name "$POLYTERM_THEME")" \
            --delimiter ' │ ' \
            --with-nth '1,2,3' \
            --preview '
                raw=$(echo {5} | xargs)
                n="${raw#:builtin:}"
                n="${n#:custom:}"
                f="$DOTFILES_ROOT/common/config/themes/$n.json"
                [ -f "$f" ] || f="$DOTFILES_DATA/settings/themes/$n.json"
                if [ -f "$f" ]; then
                    python3 -c "
import json, sys
d = json.load(open(sys.argv[1]))
c = d.get(\"colors\", {})
print(f\"  Theme: {d.get(\"name\", sys.argv[2])}\")
print()
keys=[\"black\",\"red\",\"green\",\"yellow\",\"blue\",\"purple\",\"cyan\",\"white\"]
bright=[\"brightBlack\",\"brightRed\",\"brightGreen\",\"brightYellow\",\"brightBlue\",\"brightPurple\",\"brightCyan\",\"brightWhite\"]
line=\"\"
for k in keys:
    v=c.get(k,\"#000\")
    r,g,b=int(v[1:3],16),int(v[3:5],16),int(v[5:7],16)
    line+=f\"\\033[48;2;{r};{g};{b}m  \\033[0m\"
print(f\"  Base:    {line}\")
line=\"\"
for k in bright:
    v=c.get(k,\"#000\")
    r,g,b=int(v[1:3],16),int(v[3:5],16),int(v[5:7],16)
    line+=f\"\\033[48;2;{r};{g};{b}m  \\033[0m\"
print(f\"  Bright:  {line}\")
bg=c.get(\"background\",\"#000\")
fg=c.get(\"foreground\",\"#ccc\")
r1,g1,b1=int(bg[1:3],16),int(bg[3:5],16),int(bg[5:7],16)
r2,g2,b2=int(fg[1:3],16),int(fg[3:5],16),int(fg[5:7],16)
print(f\"  BG/FG:   \\033[48;2;{r1};{g1};{b1}m\\033[38;2;{r2};{g2};{b2}m  Aa Bb Cc  \\033[0m\")
" "$f" "$n"
                else
                    echo \"  No preview available\"
                fi
            ')

        [[ -z "$selection" ]] && settings_menu && return

        local type arg
        type=$(echo "$selection" | awk -F' │ ' '{print $4}' | xargs)
        arg=$(echo "$selection" | awk -F' │ ' '{print $5}' | xargs)

        case "$type" in
            SELECT)
                local save_name="$arg"
                save_name="${save_name#:builtin:}"
                save_name="${save_name#:custom:}"
                update_setting "POLYTERM_THEME" "$save_name"
                load_theme "$arg"
                trigger_zsh_func "dot-reload"
                clear
                echo "󰄬  Theme changed to $(get_theme_display_name "$save_name")"
                sleep 1
                return
                ;;
            CUSTOMIZE)
                customize_theme_menu
                ;;
            BACK)
                settings_menu
                return
                ;;
        esac
    done
}

function settings_menu() {
    # Refresh settings
    [[ -f "$SETTINGS_FILE" ]] && source "$SETTINGS_FILE"
    
    local query=$1
    local dim="\033[2m"
    local reset="\033[0m"

    local theme_name=$(get_theme_display_name "$POLYTERM_THEME")

    local scan_push_status="[OFF]"
    [[ "$POLYTERM_SCAN_ON_PUSH" == "true" ]] && scan_push_status="[ON]"
    
    local scan_pull_status="[OFF]"
    [[ "$POLYTERM_SCAN_ON_PULL" == "true" ]] && scan_pull_status="[ON]"

    local welcome_status="[ON]"
    [[ "$POLYTERM_WELCOME" == "off" ]] && welcome_status="[OFF]"

    local settings_options="$(printf "%3s │ %-35s │ %b │ %-8s │ %s\n" "1" "󰒃  Security Check on Push $scan_push_status" "${dim}Toggle pre-push scan${reset}" "SETTING" "SCAN_PUSH")"
    settings_options+="$(printf "%3s │ %-35s │ %b │ %-8s │ %s\n" "2" "󰒃  Security Check on Pull $scan_pull_status" "${dim}Toggle post-pull scan${reset}" "SETTING" "SCAN_PULL")"
    settings_options+="$(printf "%3s │ %-35s │ %b │ %-8s │ %s\n" "3" "󰋗  Welcome Banner $welcome_status" "${dim}Toggle login welcome banner${reset}" "SETTING" "WELCOME")"
    settings_options+="$(printf "%3s │ %-35s │ %b │ %-8s │ %s\n" "4" "󰈙  Scratchpad Settings..." "${dim}Configure paths and access${reset}" "ACTION" "SCRATCHPAD")"
    settings_options+="$(printf "%3s │ %-35s │ %b │ %-8s │ %s\n" "5" "󰑐  Theme... $theme_name" "${dim}Select or customize color theme${reset}" "ACTION" "THEME")"

    local selection=$(echo -e "$settings_options" | fzf \
        --ansi \
        --height 100% \
        --reverse \
        --border rounded \
        --prompt "󰒓  " \
        --query "$query" \
        --header "Select Setting (Type index or name)" \
        --delimiter ' │ ' \
        --with-nth '1,2,3')

    if [[ -n "$selection" ]]; then
        local choice=$(echo "$selection" | awk -F'│' '{print $4}' | xargs)
        case "$choice" in
            SCAN_PUSH)
                update_setting "POLYTERM_SCAN_ON_PUSH" "$([[ "$POLYTERM_SCAN_ON_PUSH" == "true" ]] && echo false || echo true)"
                settings_menu
                ;;
            SCAN_PULL)
                update_setting "POLYTERM_SCAN_ON_PULL" "$([[ "$POLYTERM_SCAN_ON_PULL" == "true" ]] && echo false || echo true)"
                settings_menu
                ;;
            WELCOME)
                update_setting "POLYTERM_WELCOME" "$([[ "$POLYTERM_WELCOME" == "on" ]] && echo off || echo on)"
                settings_menu
                ;;
            SCRATCHPAD) scratchpad_menu ;;
            THEME) theme_menu ;;
        esac
    else
        main_menu
    fi
}
