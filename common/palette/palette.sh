#!/bin/bash

# ==========================================
# 🎛️  COMMAND PALETTE (TMUX & ZELLIJ COMPATIBLE)
# ==========================================

# 1. Capture the pane ID if inside Tmux
if [[ -n "$TMUX" ]]; then
    TARGET_PANE=$(tmux display-message -p '#{client_pane_id}')
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

# 3. FZF Theming (loaded from active theme)
# FZF_DEFAULT_OPTS will be set by themes.sh after settings are loaded

# 4. Dynamic Paths
# Prioritize user's active repository (via DOTFILES_ROOT or ~/polyterm) if valid
if [[ -n "$DOTFILES_ROOT" && -d "$DOTFILES_ROOT/common/palette" ]]; then
    REPO_PATH="$DOTFILES_ROOT"
elif [[ -d "$HOME/polyterm/common/palette" ]]; then
    REPO_PATH="$HOME/polyterm"
else
    REPO_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )/../.." && pwd )"
fi

# 4b. Data Path (separate private repo for mutable user state)
DOTFILES_DATA="${DOTFILES_DATA:-${REPO_PATH}/../polyterm-data}"

# 4c. Docs Path — bundled in dotfiles/docs/ first, then fallback to companion repo
DOCS_PATH=""
if [[ -d "${REPO_PATH}/docs" ]]; then
    DOCS_PATH="${REPO_PATH}/docs"
elif [[ -d "${REPO_PATH}/project-manager" ]]; then
    DOCS_PATH="${REPO_PATH}/project-manager"
elif [[ -d "${REPO_PATH}/../dotfiles-projectmanager/project-manager" ]]; then
    DOCS_PATH="${REPO_PATH}/../dotfiles-projectmanager/project-manager"
elif [[ -n "$POLYTERM_DOCS_PATH" && -d "$POLYTERM_DOCS_PATH" ]]; then
    DOCS_PATH="$POLYTERM_DOCS_PATH"
fi

device_id=$(hostname | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9_-]//g')

BREWFILE_PATH="${REPO_PATH}/OS/${OS_ENV}/Brewfile.apps"
if [[ -f "${REPO_PATH}/OS/${OS_ENV}/${device_id}/Brewfile.apps" ]]; then
    BREWFILE_PATH="${REPO_PATH}/OS/${OS_ENV}/${device_id}/Brewfile.apps"
fi

META_PATH="${DOTFILES_DATA}/cache/OS/${OS_ENV}/apps_meta.txt"
if [[ -f "${DOTFILES_DATA}/cache/OS/${OS_ENV}/${device_id}/apps_meta.txt" ]]; then
    META_PATH="${DOTFILES_DATA}/cache/OS/${OS_ENV}/${device_id}/apps_meta.txt"
fi

SETTINGS_FILE="${DOTFILES_DATA}/settings/.polyterm_settings"
PALETTE_LIB="${REPO_PATH}/common/palette"

# 5. Load Settings
if [[ -f "$SETTINGS_FILE" ]]; then
    source "$SETTINGS_FILE"
fi

# 6. Source Modular Scripts
source "$PALETTE_LIB/themes.sh"
source "$PALETTE_LIB/helpers.sh"
source "$PALETTE_LIB/apps.sh"
# source "$PALETTE_LIB/docs.sh"  # Deprecated: documents_menu was shadowed by menu.sh
source "$PALETTE_LIB/settings.sh"
source "$PALETTE_LIB/shortcuts.sh"
source "$PALETTE_LIB/devices.sh"
source "$PALETTE_LIB/config_manager.sh"
source "$PALETTE_LIB/menu.sh"

# ==========================================
# 🏁  INITIALIZATION
# ==========================================

if [[ "$1" == "--list" ]]; then
    list_all_items "$2"
    exit 0
fi

main_menu
