#!/bin/bash

# ==========================================
# 🎛️  TMUX COMMAND PALETTE
# ==========================================

# 1. Capture the pane ID where the palette was triggered
TARGET_PANE=$(tmux display-message -p '#{pane_id}')

# 2. OS Detection for cross-platform dotfiles
if uname -a | grep -iq "microsoft\|wsl"; then
    OS_ENV="wsl"
elif [[ "$OSTYPE" == "darwin"* ]]; then
    OS_ENV="mac"
else
    OS_ENV="linux" # Fallback for native Linux
fi

# 3. FZF Theming (Peppermint Greenish/Dark)
export FZF_DEFAULT_OPTS="--color=bg+:#2a2a2a,bg:#000000,spinner:#89d287,hl:#14b8a6,fg:#c8c8c8,header:#449fd0,info:#dab853,pointer:#14b8a6,marker:#89d287,fg+:#dfdfdf,prompt:#14b8a6,hl+:#14b8a6"

# 4. Dynamic Paths
REPO_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )"
BREWFILE_PATH="${REPO_PATH}/${OS_ENV}/Brewfile.apps"
META_PATH="${REPO_PATH}/${OS_ENV}/apps_meta.txt"
SETTINGS_FILE="${REPO_PATH}/common/.polyterm_settings"

# 5. Load Settings
if [[ -f "$SETTINGS_FILE" ]]; then
    source "$SETTINGS_FILE"
fi

# ==========================================
# 🛠️  HELPER FUNCTIONS
# ==========================================

function update_setting() {
    local key=$1
    local value=$2
    if grep -q "export $key=" "$SETTINGS_FILE"; then
        if [[ "$OS_ENV" == "mac" ]]; then
            sed -i '' "s/^export $key=.*/export $key=$value/" "$SETTINGS_FILE"
        else
            sed -i "s/^export $key=.*/export $key=$value/" "$SETTINGS_FILE"
        fi
    else
        echo "export $key=$value" >> "$SETTINGS_FILE"
    fi
    source "$SETTINGS_FILE"
}

function trigger_zsh_func() {
    local func_name=$1
    # Send the command to the original pane and execute it
    tmux send-keys -t "$TARGET_PANE" "$func_name" C-m
}

function trigger_and_sync() {
    local cmd=$1
    # Execute command and then dot-sync
    tmux send-keys -t "$TARGET_PANE" "$cmd && dot-sync" C-m
}

function confirm_action() {
    local msg="$1"
    echo -e "󰀦  $msg"
    printf "Confirm? (y/N): "
    read -r resp
    case "$resp" in
        [yY][eE][sS]|[yY]) return 0 ;;
        *) return 1 ;;
    esac
}

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

# ==========================================
# 📦  PACKAGE MANAGEMENT
# ==========================================

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
    for app in "${apps[@]}"; do
        list_items+="$app\n"
    done

    local selection
    selection=$(echo -e "$list_items" | fzf \
        --height 100% \
        --reverse \
        --border rounded \
        --prompt "󰆴  " \
        --header "Select App to Uninstall")

    if [[ -n "$selection" ]]; then
        clear
        if confirm_action "Uninstall $selection and sync to GitHub?"; then
            if [[ "$OS_ENV" == "mac" ]]; then
                sed -i '' "/^$selection|/d" "$META_PATH" 2>/dev/null
            else
                sed -i "/^$selection|/d" "$META_PATH" 2>/dev/null
            fi
            trigger_and_sync "brew uninstall --verbose $selection"
        else
            uninstall_app
        fi
    else
        main_menu
    fi
}

# ==========================================
# 🚀  MENU LOGIC
# ==========================================

function apps_menu() {
    if [[ ! -f "$BREWFILE_PATH" ]]; then
        echo -e "󰅙  Brewfile missing at:\n$BREWFILE_PATH"
        sleep 2
        main_menu
        return
    fi

    # 1. Get apps from Brewfile
    local apps=()
    while IFS= read -r line; do
        apps+=("$line")
    done < <(grep '^brew "' "$BREWFILE_PATH" | cut -d '"' -f 2)
    
    # 2. Check for missing descriptions to avoid unnecessary "Loading" delay
    local missing_apps=()
    for app in "${apps[@]}"; do
        if ! grep -q "^${app}|" "$META_PATH" 2>/dev/null; then
            missing_apps+=("$app")
        fi
    done

    # 3. Only fetch if something is missing
    if [[ ${#missing_apps[@]} -gt 0 ]]; then
        echo "󰇥  Fetching new app descriptions..."
        for app in "${missing_apps[@]}"; do
            get_app_description "$app" > /dev/null
        done
    fi

    # 4. Generate the final list quickly using awk with dimmed descriptions
    local list_items=$(awk -F'|' '
        NR==FNR { cache[$1]=$2; next }
        { 
            desc = cache[$1] ? cache[$1] : "󰒓  CLI Tool"
            print $1 " | \033[2m" desc "\033[0m"
        }
    ' "$META_PATH" <(printf "%s\n" "${apps[@]}"))

    local selection=$(echo -e "$list_items" | fzf \
        --ansi \
        --height 100% \
        --reverse \
        --border rounded \
        --prompt "󱐋  " \
        --header "󱓞  Launch App (Brewfile: $OS_ENV)" \
        --delimiter ' \| ' \
        --with-nth 1,2)

    if [[ -n "$selection" ]]; then
        local selected_app=$(echo "$selection" | cut -d '|' -f 1 | xargs)
        trigger_zsh_func "$selected_app"
    else
        main_menu
    fi
}

function shortcuts_menu() {
    local query=$1
    local mod="Alt"
    local dim="\033[2m"
    local reset="\033[0m"

    local menu_items="1 | 󰐕  New Session ($mod+,) | ${dim}Create a fresh tmux session${reset} | new-session\n"
    menu_items+="2 | 󰑐  Cycle Sessions ($mod+0) | ${dim}Switch to the next active session${reset} | switch-client -n\n"
    menu_items+="3 | 󰆴  Kill Session ($mod+w) | ${dim}Terminate the current session${reset} | kill-session\n"
    menu_items+="4 | 󰈔  New Window ($mod+m) | ${dim}Create a new tmux window${reset} | new-window\n"
    menu_items+="5 | 󰅙  Kill Window ($mod+e) | ${dim}Close the current window${reset} | kill-window\n"
    menu_items+="6 | 󰁞  Next Window ($mod+Up) | ${dim}Switch to the next window${reset} | next-window\n"
    menu_items+="7 | 󰁆  Previous Window ($mod+Down) | ${dim}Switch to the previous window${reset} | previous-window\n"
    menu_items+="8 | 󰁍  Previous Pane ($mod+Left) | ${dim}Switch to the previous pane${reset} | select-pane -t :.-\n"
    menu_items+="9 | 󰁔  Next Pane ($mod+Right) | ${dim}Switch to the next pane${reset} | select-pane -t :.+\n"
    menu_items+="10 | 󰐕  Create Pane ($mod+1) | ${dim}Split window and balance layout${reset} | split-window -c \"#{pane_current_path}\"; select-layout tiled\n"
    menu_items+="11 | 󰅖  Close Pane ($mod+2) | ${dim}Close the active pane${reset} | kill-pane; select-layout tiled"

    local selection=$(echo -e "$menu_items" | fzf \
        --ansi \
        --height 100% \
        --reverse \
        --border rounded \
        --prompt "  " \
        --query "$query" \
        --header "Select Shortcut (Type index or name)" \
        --delimiter ' \| ' \
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
    if [[ "$cmd" == "kill-session" ]]; then
        clear
        if ! confirm_action "Kill current session?"; then
            shortcuts_menu
            return
        fi
    fi
    tmux run-shell "tmux $cmd"
}

function documents_menu() {
    local query=$1
    local dim="\033[2m"
    local reset="\033[0m"
    local docs_path="${REPO_PATH}/project-manager"
    
    if [[ ! -d "$docs_path" ]]; then
        echo -e "󰅙  Project Manager directory missing!"
        sleep 2
        main_menu
        return
    fi

    local list_items=""
    local idx=1
    while IFS= read -r file; do
        local rel_path="${file#$docs_path/}"
        local display_name=$(echo "$rel_path" | sed -E 's/\.md$//; s/[\/-]/ /g; s/\b(.)/\u\1/g')
        list_items+="$idx | 󰈙  $display_name | ${dim}Read $rel_path${reset} | $file\n"
        ((idx++))
    done < <(find "$docs_path" -type f -name "*.md" | sort)

    local selection=$(echo -e "$list_items" | fzf \
        --ansi \
        --height 100% \
        --reverse \
        --border rounded \
        --prompt "󱓡  " \
        --query "$query" \
        --header "Select Document (Type index or name)" \
        --delimiter ' \| ' \
        --with-nth 1,2,3)

    if [[ -n "$selection" ]]; then
        local selected_file=$(echo "$selection" | cut -d '|' -f 4 | xargs)
        read_document "$selected_file"
        documents_menu
    else
        main_menu
    fi
}

function read_document() {
    local file=$1
    clear
    if command -v glow &>/dev/null; then
        glow -p "$file"
    else
        less "$file"
    fi
}

function settings_menu() {
    local query=$1
    local dim="\033[2m"
    local reset="\033[0m"
    
    local scan_push_status="[OFF]"
    [[ "$POLYTERM_SCAN_ON_PUSH" == "true" ]] && scan_push_status="[ON]"
    
    local scan_pull_status="[OFF]"
    [[ "$POLYTERM_SCAN_ON_PULL" == "true" ]] && scan_pull_status="[ON]"

    local settings_options="1 | 󰒃  Security Check on Push $scan_push_status | ${dim}Toggle pre-push scan${reset} | SCAN_PUSH\n"
    settings_options+="2 | 󰒃  Security Check on Pull $scan_pull_status | ${dim}Toggle post-pull scan${reset} | SCAN_PULL"

    local selection=$(echo -e "$settings_options" | fzf \
        --ansi \
        --height 100% \
        --reverse \
        --border rounded \
        --prompt "󰒓  " \
        --query "$query" \
        --header "Select Setting (Type index or name)" \
        --delimiter ' \| ' \
        --with-nth 1,2,3)

    if [[ -n "$selection" ]]; then
        local choice=$(echo "$selection" | cut -d '|' -f 4 | xargs)
        toggle_setting "$choice"
        settings_menu
    else
        main_menu
    fi
}

function toggle_setting() {
    local setting=$1
    case "$setting" in
        SCAN_PUSH)
            if [[ "$POLYTERM_SCAN_ON_PUSH" == "true" ]]; then
                update_setting "POLYTERM_SCAN_ON_PUSH" "false"
            else
                update_setting "POLYTERM_SCAN_ON_PUSH" "true"
            fi
            ;;
        SCAN_PULL)
            if [[ "$POLYTERM_SCAN_ON_PULL" == "true" ]]; then
                update_setting "POLYTERM_SCAN_ON_PULL" "false"
            else
                update_setting "POLYTERM_SCAN_ON_PULL" "true"
            fi
            ;;
    esac
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

    # Generate the final list with indices
    local list_items=$(awk -F'|' '
        NR==FNR { cache[$1]=$2; next }
        { 
            idx++
            desc = cache[$1] ? cache[$1] : "󰒓  CLI Tool"
            print idx " | " $1 " | \033[2m" desc "\033[0m"
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
        --delimiter ' \| ' \
        --with-nth 1,2,3)

    if [[ -n "$selection" ]]; then
        local selected_app=$(echo "$selection" | cut -d '|' -f 2 | xargs)
        trigger_zsh_func "$selected_app"
    else
        main_menu
    fi
}

function list_all_items() {
    local query=$1
    local dim="\033[2m"
    local reset="\033[0m"
    local mod="Alt"
    local idx=0

    if [[ -z "$query" ]]; then
        echo -e "1 | 󱓞  Launch App... | ${dim}Browse and launch installed CLI tools${reset} | CAT | apps"
        echo -e "2 | 󰈙  Project Documents... | ${dim}Read all documentation in project-manager/${reset} | CAT | docs"
        echo -e "3 | 󰒓  Settings... | ${dim}Tweak security and UX preferences${reset} | CAT | settings"
        echo -e "4 |   Execute Shortcut... | ${dim}Run Tmux window and pane commands${reset} | CAT | shortcuts"
        echo -e "5 | 󰏔  Install App | ${dim}Install new packages via Homebrew${reset} | ACTION | install"
        echo -e "6 | 󰆴  Uninstall App | ${dim}Remove packages and sync to GitHub${reset} | ACTION | uninstall"
        echo -e "7 | 󰇚  Pull Changes | ${dim}Fetch latest updates from GitHub${reset} | ACTION | pull"
        echo -e "8 | 󰇶  Push Changes | ${dim}Sync local configs to GitHub (Self-Healing)${reset} | ACTION | push"
        echo -e "9 |   Reload All Configs | ${dim}Refresh Zsh and Tmux environments${reset} | ACTION | reload"
        echo -e "10 | 󰒃  Security Scan | ${dim}Run audit and package vulnerability checks${reset} | ACTION | scan"
        echo -e "11 | 󰌌  Fix Alt Keys | ${dim}Diagnose and resolve keyboard issues${reset} | ACTION | fix_alt"
        echo -e "12 | 󰅙  Exit | ${dim}Close the command palette${reset} | ACTION | exit"
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
        ((idx++))
        echo -e "$idx | 󰒃  Security Check on Push $scan_push_status | ${dim}Toggle pre-push scan${reset} | SETTING | SCAN_PUSH"
        ((idx++))
        echo -e "$idx | 󰒃  Security Check on Pull $scan_pull_status | ${dim}Toggle post-pull scan${reset} | SETTING | SCAN_PULL"
        # 4. Shortcuts
        ((idx++)); echo -e "$idx | 󰐕  New Session ($mod+,) | ${dim}Create fresh session${reset} | SHORTCUT | new-session"
        ((idx++)); echo -e "$idx | 󰑐  Cycle Sessions ($mod+0) | ${dim}Switch next session${reset} | SHORTCUT | switch-client -n"
        ((idx++)); echo -e "$idx | 󰆴  Kill Session ($mod+w) | ${dim}Terminate session${reset} | SHORTCUT | kill-session"
        ((idx++)); echo -e "$idx | 󰈔  New Window ($mod+m) | ${dim}Create new window${reset} | SHORTCUT | new-window"
        ((idx++)); echo -e "$idx | 󰅙  Kill Window ($mod+e) | ${dim}Close window${reset} | SHORTCUT | kill-window"
        # 5. Actions
        ((idx++)); echo -e "$idx | 󰏔  Install App | ${dim}Install via Homebrew${reset} | ACTION | install"
        ((idx++)); echo -e "$idx | 󰆴  Uninstall App | ${dim}Remove and sync${reset} | ACTION | uninstall"
        ((idx++)); echo -e "$idx | 󰇚  Pull Changes | ${dim}Fetch from GitHub${reset} | ACTION | pull"
        ((idx++)); echo -e "$idx | 󰇶  Push Changes | ${dim}Sync to GitHub${reset} | ACTION | push"
        ((idx++)); echo -e "$idx |   Reload All Configs | ${dim}Refresh env${reset} | ACTION | reload"
        ((idx++)); echo -e "$idx | 󰒃  Security Scan | ${dim}Run audit${reset} | ACTION | scan"
    fi
}

function main_menu() {
    # fzf with visible search field and index-based selection support
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
    # Dispatcher: Detect selection source
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
        SETTING) toggle_setting "$arg"; settings_menu ;;
        SHORTCUT) execute_shortcut "$arg" ;;
        ACTION)
            case "$arg" in
                install) install_app ;;
                uninstall) uninstall_app ;;
                pull) trigger_zsh_func "dot-pull" ;;
                push) trigger_zsh_func "dot-sync" ;;
                reload) trigger_zsh_func "source ~/.zshrc && dot-reload" ;;
                scan) trigger_zsh_func "dot-scan" ;;
                fix_alt) clear; "$REPO_PATH/common/fix-alt-keys.sh"; printf "Press Enter to return..."; read -r; main_menu ;;
                exit) exit 0 ;;
            esac
            ;;
    esac
}





# ==========================================
# 🏁  INITIALIZATION
# ==========================================

# Check if script is called for listing (fzf reload callback)
if [[ "$1" == "--list" ]]; then
    list_all_items "$2"
    exit 0
fi

main_menu
