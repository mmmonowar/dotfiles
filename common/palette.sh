#!/bin/bash

# ==========================================
# 🎛️  TMUX COMMAND PALETTE (MAIN)
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
OS_ENV_UPPER=$(echo "$OS_ENV" | tr '[:lower:]' '[:upper:]')

# 3. FZF Theming (Peppermint Greenish/Dark)
export FZF_DEFAULT_OPTS="--color=bg+:#2a2a2a,bg:#000000,spinner:#89d287,hl:#14b8a6,fg:#c8c8c8,header:#449fd0,info:#dab853,pointer:#14b8a6,marker:#89d287,fg+:#dfdfdf,prompt:#14b8a6,hl+:#14b8a6,query:#89d287"

# 4. Dynamic Paths
REPO_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )"
BREWFILE_PATH="${REPO_PATH}/${OS_ENV}/Brewfile.apps"
META_PATH="${REPO_PATH}/${OS_ENV}/apps_meta.txt"
SETTINGS_FILE="${REPO_PATH}/common/.polyterm_settings"
PALETTE_LIB="${REPO_PATH}/common/palette"

# 5. Load Settings
if [[ -f "$SETTINGS_FILE" ]]; then
    source "$SETTINGS_FILE"
fi

# 6. Source Modular Scripts
source "$PALETTE_LIB/helpers.sh"
source "$PALETTE_LIB/apps.sh"
source "$PALETTE_LIB/docs.sh"
source "$PALETTE_LIB/settings.sh"
source "$PALETTE_LIB/shortcuts.sh"
source "$PALETTE_LIB/menu.sh"

# ==========================================
# 🏁  INITIALIZATION
# ==========================================

if [[ "$1" == "--list" ]]; then
    list_all_items "$2"
    exit 0
fi

main_menu
