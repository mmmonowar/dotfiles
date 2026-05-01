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
