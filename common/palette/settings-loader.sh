#!/bin/bash

# ==========================================
# ⚙️ UNIFIED SETTINGS & THEME LOADER
# ==========================================
# This script is the single source of truth for loading all environment
# variables and theme settings for the PolyTerm environment.

# 1. Ensure Core Paths are Set
# DOTFILES_ROOT should be exported by the calling shell profile (e.g., zshrc).
if [[ -z "$DOTFILES_ROOT" ]]; then
    # Fallback for standalone script execution, though not the primary use case.
    export DOTFILES_ROOT="${${${(%):-%x}:A}:h:h:h}"
fi

# DOTFILES_DATA should also be set, but we can provide a default.
export DOTFILES_DATA="${DOTFILES_DATA:-${DOTFILES_ROOT}/../polyterm-data}"

# 2. Load User Settings
# Source the main settings file which contains user overrides and preferences.
local SETTINGS_FILE="${DOTFILES_DATA}/settings/.polyterm_settings"
if [[ -f "$SETTINGS_FILE" ]]; then
    source "$SETTINGS_FILE"
elif [[ -f "${DOTFILES_ROOT}/common/config/polyterm/.polyterm_settings" ]]; then
    # Fallback: pre-migration location (dotfiles/ still had settings)
    source "${DOTFILES_ROOT}/common/config/polyterm/.polyterm_settings"
fi

# 3. Ensure Zellij Paths (with defaults so config.kdl doesn't break if settings file is missing)
export POLYTERM_PATH_ZELLIJ_LAYOUTS="${POLYTERM_PATH_ZELLIJ_LAYOUTS:-${DOTFILES_ROOT}/common/config/zellij/layouts/}"
export POLYTERM_PATH_ZELLIJ_THEMES="${POLYTERM_PATH_ZELLIJ_THEMES:-${DOTFILES_ROOT}/common/config/zellij/themes/}"

# 4. Load Theme Engine
# This script reads the POLYTERM_THEME variable and exports all necessary
# POLYTERM_COLOR_* and POLYTERM_FZF_* variables for theming.
local THEME_ENGINE_SCRIPT="$DOTFILES_ROOT/common/palette/themes.sh"
if [[ -f "$THEME_ENGINE_SCRIPT" ]]; then
    source "$THEME_ENGINE_SCRIPT"
fi
