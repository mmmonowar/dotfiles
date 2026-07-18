#!/bin/zsh

# hledger synchronization helper
# Ensures ~/.hledger.journal is linked to the Accounting Management System repository.

function sync_hledger() {
    local HLEDGER_LINK="$HOME/.hledger.journal"
    local HLEDGER_REPO_DIR="${POLYTERM_HLEDGER_REPO:-$HOME/GitHub/INTxK/Accounting-Management-System}"
    local HLEDGER_REPO_DATA_DIR="$HLEDGER_REPO_DIR/hledger/data"
    local HLEDGER_REPO_FILE="$HLEDGER_REPO_DATA_DIR/hledger.journal"
    local HLEDGER_REPO_HIDDEN_FILE="$HLEDGER_REPO_DATA_DIR/.hledger.journal"

    if [[ -d "$HLEDGER_REPO_DIR" ]]; then
        # Create destination directory if missing
        mkdir -p "$HLEDGER_REPO_DATA_DIR"

        # Migration: Rename hidden file to visible file if it exists
        if [[ -f "$HLEDGER_REPO_HIDDEN_FILE" ]] && [[ ! -f "$HLEDGER_REPO_FILE" ]]; then
            mv "$HLEDGER_REPO_HIDDEN_FILE" "$HLEDGER_REPO_FILE"
        fi

        # Setup/Link Logic
        if [[ -L "$HLEDGER_LINK" ]]; then
            # Already a link, check if it points to the right place
            local current_target=$(readlink "$HLEDGER_LINK")
            if [[ "$current_target" != "$HLEDGER_REPO_FILE" ]]; then
                echo "󱍢  Updating hledger symlink to $HLEDGER_REPO_FILE..."
                ln -sf "$HLEDGER_REPO_FILE" "$HLEDGER_LINK"
            fi
        elif [[ -f "$HLEDGER_LINK" ]]; then
            # It's a real file, migrate it to repo
            echo "󱍢  Migrating local hledger journal to $HLEDGER_REPO_FILE..."
            if [[ ! -f "$HLEDGER_REPO_FILE" ]] || [[ "$HLEDGER_LINK" -nt "$HLEDGER_REPO_FILE" ]]; then
                cp "$HLEDGER_LINK" "$HLEDGER_REPO_FILE"
            fi
            mv "$HLEDGER_LINK" "$HLEDGER_LINK.bak"
            ln -s "$HLEDGER_REPO_FILE" "$HLEDGER_LINK"
            echo "󰄬  Migration complete. Original backed up to $HLEDGER_LINK.bak"
        elif [[ -f "$HLEDGER_REPO_FILE" ]]; then
            # Link missing but repo file exists
            echo "🔗  Linking $HLEDGER_LINK -> $HLEDGER_REPO_FILE"
            ln -s "$HLEDGER_REPO_FILE" "$HLEDGER_LINK"
        fi
        
        if [[ -f "$HLEDGER_REPO_FILE" ]]; then
            echo "󰄬  hledger data is active in $HLEDGER_REPO_DATA_DIR"
        fi
    fi
}

sync_hledger
