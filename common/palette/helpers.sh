#!/bin/bash

# ==========================================
# 🛠️  HELPER FUNCTIONS (TMUX & ZELLIJ COMPATIBLE)
# ==========================================

function update_setting() {
    local key=$1
    local value=$2
    
    # Portability Fix: Replace literal HOME path with $HOME variable
    # We use a placeholder to avoid expansion during the sed operation
    local sanitized_value=$(echo "$value" | sed "s|$HOME|\$HOME|g")
    
    if grep -q "export $key=" "$SETTINGS_FILE"; then
        if [[ "$OS_ENV" == "mac" ]]; then
            sed -i '' "s|^export $key=.*|export $key=\"$sanitized_value\"|" "$SETTINGS_FILE"
        else
            sed -i "s|^export $key=.*|export $key=\"$sanitized_value\"|" "$SETTINGS_FILE"
        fi
    else
        echo "export $key=\"$sanitized_value\"" >> "$SETTINGS_FILE"
    fi
    # Re-source to update current environment
    source "$SETTINGS_FILE"
}

function trigger_zsh_func() {
    local func_name=$1
    if [[ -n "$ZELLIJ" ]]; then
        # Dynamically find the target tiled pane in Zellij
        local target_pane
        target_pane=$(zellij action list-panes --json 2>/dev/null | python3 -c '
import sys, json
try:
    data = json.load(sys.stdin)
    my_id = sys.argv[1] if len(sys.argv) > 1 else ""
    my_pane = next((p for p in data if str(p.get("id")) == my_id), None) if my_id else None
    if not my_pane:
        my_pane = next((p for p in data if p.get("is_focused") and p.get("is_floating")), None)
    if my_pane:
        tab_id = my_pane.get("tab_id")
        candidates = [p for p in data if p.get("tab_id") == tab_id and not p.get("is_floating") and not p.get("is_plugin")]
        if candidates:
            print(candidates[0]["id"])
except Exception:
    pass
' "$ZELLIJ_PANE_ID")

        if [[ -n "$target_pane" ]]; then
            zellij action write-chars --pane-id "$target_pane" "$func_name"
            zellij action send-keys --pane-id "$target_pane" "Enter"
        fi
        zellij action close-pane
    else
        # Tmux
        tmux send-keys -t "$TARGET_PANE" "$func_name" C-m
    fi
}

function trigger_and_sync() {
    local cmd=$1
    if [[ -n "$ZELLIJ" ]]; then
        # Dynamically find the target tiled pane in Zellij
        local target_pane
        target_pane=$(zellij action list-panes --json 2>/dev/null | python3 -c '
import sys, json
try:
    data = json.load(sys.stdin)
    my_id = sys.argv[1] if len(sys.argv) > 1 else ""
    my_pane = next((p for p in data if str(p.get("id")) == my_id), None) if my_id else None
    if not my_pane:
        my_pane = next((p for p in data if p.get("is_focused") and p.get("is_floating")), None)
    if my_pane:
        tab_id = my_pane.get("tab_id")
        candidates = [p for p in data if p.get("tab_id") == tab_id and not p.get("is_floating") and not p.get("is_plugin")]
        if candidates:
            print(candidates[0]["id"])
except Exception:
    pass
' "$ZELLIJ_PANE_ID")

        if [[ -n "$target_pane" ]]; then
            zellij action write-chars --pane-id "$target_pane" "$cmd && dot-sync"
            zellij action send-keys --pane-id "$target_pane" "Enter"
        fi
        zellij action close-pane
    else
        # Tmux
        tmux send-keys -t "$TARGET_PANE" "$cmd && dot-sync" C-m
    fi
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

function truncate_desc() {
    local desc="$1"
    local max_len="${2:-auto}"

    if [[ "$max_len" == "auto" ]]; then
        local term_width
        term_width=$(tput cols 2>/dev/null || echo 80)
        local overhead=37
        max_len=$((term_width - overhead))
        [[ $max_len -lt 20 ]] && max_len=20
    fi

    local plain
    plain=$(echo -e "$desc" | sed 's/\x1b\[[0-9;]*m//g')
    if [[ ${#plain} -gt $max_len ]]; then
        local truncated="${plain:0:$((max_len-1))}…"
        if [[ "$desc" == *$'\x1b['* ]]; then
            echo -e "\033[2m${truncated}\033[0m"
        else
            echo "$truncated"
        fi
    else
        echo "$desc"
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

function kill_gemini_processes() {
    clear
    if confirm_action "Kill all Gemini processes across all sessions?"; then
        echo -e "\n󰅙  Terminating Gemini processes..."
        
        # Get current process PID and its parent
        local current_pid=$$
        local parent_pid=$(ps -o ppid= -p "$current_pid" | xargs)
        
        # Identify all gemini-related processes
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
