#!/bin/bash

# ==========================================
# 🎛️  COMMAND PALETTE (TMUX & ZELLIJ COMPATIBLE)
# ==========================================

# 1. Capture the pane ID if inside Tmux
if [[ -n "$TMUX" ]]; then
    TARGET_PANE=$(tmux display-message -p '#{pane_id}')
fi

# 2. OS Detection for cross-platform dotfiles
if uname -a | grep -iq "microsoft\|wsl"; then
    OS_ENV="wsl"
elif [[ "$OSTYPE" == "darwin"* ]]; then
    OS_ENV="mac"
else
    OS_ENV="linux"
fi
OS_ENV_UPPER=$(echo "$OS_ENV" | tr '[:lower:]' '[:upper:]' )

# 3. FZF Theming (Peppermint Greenish/Dark)
export FZF_DEFAULT_OPTS="--color=bg+:#2a2a2a,bg:#000000,spinner:#89d287,hl:#14b8a6,fg:#c8c8c8,header:#449fd0,info:#dab853,pointer:#14b8a6,marker:#89d287,fg+:#dfdfdf,prompt:#14b8a6,hl+:#14b8a6,query:#89d287"

# 4. Dynamic Paths
# Prioritize user's active repository (via DOTFILES_ROOT or ~/dotfiles) if valid
if [[ -n "$DOTFILES_ROOT" && -d "$DOTFILES_ROOT/common/palette" ]]; then
    REPO_PATH="$DOTFILES_ROOT"
elif [[ -d "$HOME/dotfiles/common/palette" ]]; then
    REPO_PATH="$HOME/dotfiles"
else
    REPO_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )/../.." && pwd )"
fi

device_id=$(hostname | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9_-]//g')

BREWFILE_PATH="${REPO_PATH}/OS/${OS_ENV}/Brewfile.apps"
if [[ -f "${REPO_PATH}/OS/${OS_ENV}/${device_id}/Brewfile.apps" ]]; then
    BREWFILE_PATH="${REPO_PATH}/OS/${OS_ENV}/${device_id}/Brewfile.apps"
fi

META_PATH="${REPO_PATH}/OS/${OS_ENV}/apps_meta.txt"
if [[ -f "${REPO_PATH}/OS/${OS_ENV}/${device_id}/apps_meta.txt" ]]; then
    META_PATH="${REPO_PATH}/OS/${OS_ENV}/${device_id}/apps_meta.txt"
fi

SETTINGS_FILE="${REPO_PATH}/common/config/polyterm/.polyterm_settings"
PALETTE_LIB="${REPO_PATH}/common/palette"

# 5. Load Settings
if [[ -f "$SETTINGS_FILE" ]]; then
    source "$SETTINGS_FILE"
fi

# 6. Source Modular Scripts
source "$PALETTE_LIB/helpers.sh"
source "$PALETTE_LIB/apps.sh"
# source "$PALETTE_LIB/docs.sh"  # Deprecated: documents_menu was shadowed by menu.sh
source "$PALETTE_LIB/settings.sh"
source "$PALETTE_LIB/shortcuts.sh"
source "$PALETTE_LIB/devices.sh"
source "$PALETTE_LIB/menu.sh"

# ==========================================
# 🏁  INITIALIZATION
# ==========================================

if [[ "$1" == "--list" ]]; then
    list_all_items "$2"
    exit 0
fi

main_menu
