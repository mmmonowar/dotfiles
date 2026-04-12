#!/bin/bash

# Configuration
BREWFILE_PATH="$HOME/dotfiles/wsl/Brewfile"
META_PATH="$HOME/dotfiles/wsl/apps_meta.txt"
TARGET_PANE=$(tmux display-message -p '#{pane_id}')

function main_menu() {
    options="1. 🚀 Apps (Launch)
2. 📦 Install App
3. 🗑️  Uninstall App
4. ⬇️  Pull Remote Changes
5. ⬆️  Push Local Changes (Sync)
6. 🔄 Refresh Tmux
7. ❌ Exit"

    choice=$(echo -e "$options" | fzf --prompt="󱂬 Cockpit > " --height=100% --layout=reverse --border)

    case "$choice" in
        *1.*) apps_menu ;;
        *2.*) install_app ;;
        *3.*) uninstall_app ;;
        *4.*) trigger_zsh_func "dotpull" ;;
        *5.*) trigger_zsh_func "dot-sync" ;;
        *6.*) reload_tmux ;;
        *) exit 0 ;;
    esac
}

function trigger_zsh_func() {
    local func_name=$1
    tmux send-keys -t "$TARGET_PANE" "$func_name" C-m
}

function install_app() {
    echo -n "Enter package name: "
    read -r app_name
    [[ -z "$app_name" ]] && main_menu && return

    echo -n "Enter menu description (e.g., 🚀 My App): "
    read -r app_desc

    # Ensure meta file exists and append the new description
    touch "$META_PATH"
    if [[ -n "$app_desc" ]]; then
        # Remove any existing entry for this app to prevent duplicates, then append
        sed -i "/^${app_name}|/d" "$META_PATH" 2>/dev/null
        echo "${app_name}|${app_desc}" >> "$META_PATH"
    fi

    echo "--- Queuing Install & Sync ---"
    tmux send-keys -t "$TARGET_PANE" "brew install $app_name && brew bundle dump --file=$BREWFILE_PATH --force && dot-sync" C-m
    main_menu
}

function uninstall_app() {
    if [[ ! -f "$BREWFILE_PATH" ]]; then
        echo "Brewfile not found!"; sleep 2; main_menu; return
    fi

    # Pick from currently installed apps
    app_choice=$(grep '^brew ' "$BREWFILE_PATH" | sed 's/brew "\(.*\)"/\1/' | fzf --prompt="🗑️ Uninstall > " --height=100% --layout=reverse)

    if [[ -n "$app_choice" ]]; then
        # Clean up the sidecar file
        sed -i "/^${app_choice}|/d" "$META_PATH" 2>/dev/null
        
        echo "--- Queuing Uninstall & Sync ---"
        tmux send-keys -t "$TARGET_PANE" "brew uninstall $app_choice && brew bundle dump --file=$BREWFILE_PATH --force && dot-sync" C-m
    fi
    main_menu
}

function get_app_description() {
    local app_name="$1"
    # Look for the exact app name in the sidecar file
    if [[ -f "$META_PATH" ]]; then
        local desc=$(grep "^${app_name}|" "$META_PATH" | cut -d'|' -f2-)
        if [[ -n "$desc" ]]; then
            echo "$desc"
            return
        fi
    fi
    # Fallback if no description exists
    echo "⚙️  CLI Tool"
}

function apps_menu() {
    [[ ! -f "$BREWFILE_PATH" ]] && { echo "Brewfile missing"; sleep 2; main_menu; return; }

    local dynamic_list=""
    
    for app in $(grep '^brew ' "$BREWFILE_PATH" | sed 's/brew "\(.*\)"/\1/'); do
        local desc=$(get_app_description "$app")
        dynamic_list+="$(printf "%-15s | %s\n" "$app" "$desc")"
    done

    choice=$(echo -e "$dynamic_list" | fzf --prompt="🚀 Launch > " --height=40% --layout=reverse --border --delimiter '\|' --with-nth 1,2)

    [[ -z "$choice" ]] && main_menu && return

    local cmd=$(echo "$choice" | cut -d'|' -f1 | xargs)
    tmux send-keys -t "$TARGET_PANE" "$cmd" C-m
    exit 0
}

function reload_tmux() {
    tmux source-file ~/.tmux.conf
    ~/.tmux/plugins/tpm/bin/install_plugins
    tmux display-message "Tmux Reloaded!"
}

main_menu