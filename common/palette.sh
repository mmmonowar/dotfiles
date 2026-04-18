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

# 3. Dynamic Paths
REPO_PATH="$HOME/GitHub/mmmonowar/dotfiles"
BREWFILE_PATH="${REPO_PATH}/${OS_ENV}/Brewfile"
META_PATH="${REPO_PATH}/${OS_ENV}/apps_meta.txt"

# ==========================================
# 🛠️  HELPER FUNCTIONS
# ==========================================

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
    echo -e "  $msg"
    read -p "Confirm? (y/N): " resp
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
    read -p "Enter package name (or press Enter to cancel): " app_name
    
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

    local apps=($(grep '^brew "' "$BREWFILE_PATH" | cut -d '"' -f 2))
    local list_items=""
    for app in "${apps[@]}"; do
        list_items+="$app\n"
    done

    local selection=$(echo -e "$list_items" | fzf \
        --height 100% \
        --reverse \
        --border rounded \
        --prompt "󰆴  " \
        --header "Select App to Uninstall")

    if [[ -n "$selection" ]]; then
        clear
        if confirm_action "Uninstall $selection and sync to GitHub?"; then
            sed -i "/^$selection|/d" "$META_PATH" 2>/dev/null
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
    local apps=($(grep '^brew "' "$BREWFILE_PATH" | cut -d '"' -f 2))
    
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

    # 4. Generate the final list quickly using awk
    local list_items=$(awk -F'|' '
        NR==FNR { cache[$1]=$2; next }
        { 
            desc = cache[$1] ? cache[$1] : "󰒓  CLI Tool"
            print $1 " | " desc
        }
    ' "$META_PATH" <(printf "%s\n" "${apps[@]}"))

    local selection=$(echo -e "$list_items" | fzf \
        --height 100% \
        --reverse \
        --border rounded \
        --prompt "󱐋  " \
        --header "󰀶  Launch App (Brewfile: $OS_ENV)" \
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
    local menu_items="󰐕  New Session (Alt+,) | new-session\n"
    menu_items+="󰑐  Cycle Sessions (Alt+0) | switch-client -n\n"
    menu_items+="󰆴  Kill Session (Alt+w) | kill-session\n"
    menu_items+="󰈔  New Window (Alt+m) | new-window\n"
    menu_items+="󰅙  Kill Window (Alt+e) | kill-window\n"
    menu_items+="󰁞  Next Window (Alt+Up) | next-window\n"
    menu_items+="󰁆  Previous Window (Alt+Down) | previous-window\n"
    menu_items+="󰁍  Previous Pane (Alt+Left) | select-pane -t :.-\n"
    menu_items+="󰁔  Next Pane (Alt+Right) | select-pane -t :.+\n"
    menu_items+="󰐕  Create Pane (Alt+1) | split-window -c \"#{pane_current_path}\"; select-layout tiled\n"
    menu_items+="󰅖  Close Pane (Alt+2) | kill-pane; select-layout tiled"

    local selection=$(echo -e "$menu_items" | fzf \
        --height 100% \
        --reverse \
        --border rounded \
        --prompt "  " \
        --header "Select a Shortcut to Execute" \
        --delimiter ' \| ' \
        --with-nth 1)

    if [[ -n "$selection" ]]; then
        local cmd=$(echo "$selection" | cut -d '|' -f 2 | xargs)
        
        if [[ "$cmd" == "kill-session" ]]; then
            clear
            if ! confirm_action "Kill current session?"; then
                shortcuts_menu
                return
            fi
        fi

        tmux run-shell "tmux $cmd"
    else
        main_menu
    fi
}

function main_menu() {
    local menu_options="1 | 󰀶  Launch App\n2 | 󰏔  Install App\n3 | 󰆴  Uninstall App\n4 |   Execute Shortcut\n5 | 󰇚  Pull Changes\n6 | 󰇶  Push Changes\n7 |   Reload All Configs\n8 | 󰅙  Exit"

    local selection=$(echo -e "$menu_options" | fzf \
        --height 100% \
        --reverse \
        --border rounded \
        --prompt "  " \
        --header "󰍜  Command Palette ($OS_ENV)" \
        --delimiter ' \| ' \
        --with-nth 2)

    local choice=$(echo "$selection" | cut -d '|' -f 1 | xargs)

    case "$choice" in
        1) apps_menu ;;
        2) install_app ;;
        3) uninstall_app ;;
        4) shortcuts_menu ;;
        5) trigger_zsh_func "dot-pull" ;;
        6) trigger_zsh_func "dot-sync" ;;
        7) trigger_zsh_func "dot-reload" ;;
        8|*) exit 0 ;;
    esac
}

# ==========================================
# 🏁  INITIALIZATION
# ==========================================

main_menu
