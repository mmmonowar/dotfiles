#!/bin/zsh

# hledger synchronization helper
# Ensures ~/.hledger.journal is linked to the hledger journal inside dotfiles-data.

function sync_hledger() {
    local HLEDGER_LINK="$HOME/.hledger.journal"
    local device_id=$(hostname | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9_-]//g')
    local HLEDGER_DATA_DIR="${DOTFILES_DATA}/hledger/${device_id}"
    local HLEDGER_FILE="$HLEDGER_DATA_DIR/hledger.journal"
    local HLEDGER_HIDDEN_FILE="$HLEDGER_DATA_DIR/.hledger.journal"

    # Create destination directory if missing
    mkdir -p "$HLEDGER_DATA_DIR"

    # Migration: Rename hidden file to visible file if it exists
    if [[ -f "$HLEDGER_HIDDEN_FILE" ]] && [[ ! -f "$HLEDGER_FILE" ]]; then
        mv "$HLEDGER_HIDDEN_FILE" "$HLEDGER_FILE"
    fi

    # Setup/Link Logic
    if [[ -L "$HLEDGER_LINK" ]]; then
        # Already a link, check if it points to the right place
        local current_target=$(readlink "$HLEDGER_LINK")
        if [[ "$current_target" != "$HLEDGER_FILE" ]]; then
            echo "󱍢  Updating hledger symlink to $HLEDGER_FILE..."
            ln -sf "$HLEDGER_FILE" "$HLEDGER_LINK"
        fi
    elif [[ -f "$HLEDGER_LINK" ]]; then
        # It's a real file, migrate it into dotfiles-data
        echo "󱍢  Migrating local hledger journal to $HLEDGER_FILE..."
        if [[ ! -f "$HLEDGER_FILE" ]] || [[ "$HLEDGER_LINK" -nt "$HLEDGER_FILE" ]]; then
            cp "$HLEDGER_LINK" "$HLEDGER_FILE"
        fi
        mv "$HLEDGER_LINK" "$HLEDGER_LINK.bak"
        ln -s "$HLEDGER_FILE" "$HLEDGER_LINK"
        echo "󰄬  Migration complete. Original backed up to $HLEDGER_LINK.bak"
    elif [[ -f "$HLEDGER_FILE" ]]; then
        # Link missing but journal file exists in dotfiles-data
        echo "🔗  Linking $HLEDGER_LINK -> $HLEDGER_FILE"
        ln -s "$HLEDGER_FILE" "$HLEDGER_LINK"
    fi
    
    if [[ -f "$HLEDGER_FILE" ]]; then
        echo "󰄬  hledger data is active in $HLEDGER_DATA_DIR"
    fi
}

sync_hledger
