#!/bin/bash

# ==========================================
# 🛠️  HELPER FUNCTIONS
# ==========================================

function update_setting() {
    local key=$1
    local value=$2
    if grep -q "export $key=" "$SETTINGS_FILE"; then
        if [[ "$OS_ENV" == "mac" ]]; then
            sed -i '' "s|^export $key=.*|export $key=\"$value\"|" "$SETTINGS_FILE"
        else
            sed -i "s|^export $key=.*|export $key=\"$value\"|" "$SETTINGS_FILE"
        fi
    else
        echo "export $key=\"$value\"" >> "$SETTINGS_FILE"
    fi
    # Re-source to update current environment
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

function read_document() {
    local file=$1
    clear
    if command -v glow &>/dev/null; then
        glow -p "$file"
    else
        less "$file"
    fi
}

function kill_gemini_processes() {
    clear
    if confirm_action "Kill all Gemini processes across all sessions?"; then
        echo -e "\n󰅙  Terminating Gemini processes..."
        
        # Get current process PID and its parent
        local current_pid=$$
        local parent_pid=$(ps -o ppid= -p "$current_pid" | xargs)
        
        # Identify all gemini-related processes
        # We filter out the current PID and the parent PID to avoid killing the active agent
        local pids=$(pgrep -f "gemini" | grep -vE "($current_pid|$parent_pid)")
        
        if [[ -n "$pids" ]]; then
            echo "$pids" | xargs kill -9 2>/dev/null
            echo -e "󰄬  Processes terminated."
        else
            echo -e "󰄬  No other Gemini processes found."
        fi
        
        printf "\nPress Enter to return..."
        read -r
        main_menu
    else
        main_menu
    fi
}
