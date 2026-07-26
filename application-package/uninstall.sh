#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Refuse to run as root
if [[ $EUID -eq 0 ]]; then
    echo -e "${RED}This script must not be run as root.${NC}"
    exit 1
fi

# OS Detection
if [[ "$OSTYPE" == "darwin"* ]]; then
    OS_ENV="mac"
elif uname -a | grep -iq "microsoft\|wsl"; then
    OS_ENV="wsl"
else
    OS_ENV="linux"
fi

# Resolve repository path (same logic as bin/polyterm)
if [[ -n "$DOTFILES_ROOT" && -d "$DOTFILES_ROOT/common/palette" ]]; then
    TARGET_DIR="$DOTFILES_ROOT"
elif [[ -d "$HOME/polyterm/common/palette" ]]; then
    TARGET_DIR="$HOME/polyterm"
else
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    TARGET_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
fi

DATA_DIR="$TARGET_DIR/../polyterm-data"

device_id=$(hostname | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9_-]//g')

REMOVE_REPOS=false
UNINSTALL_PACKAGES=false

# Source the offboarding wizard
OFFBOARDING_SCRIPT="$TARGET_DIR/common/palette/offboarding.sh"
if [ ! -f "$OFFBOARDING_SCRIPT" ]; then
    echo -e "${RED}Offboarding wizard not found at $OFFBOARDING_SCRIPT${NC}"
    echo -e "${YELLOW}Run this script from within the PolyTerm repository.${NC}"
    exit 1
fi

export OS_ENV
export TARGET_DIR
export DATA_DIR
export device_id

source "$OFFBOARDING_SCRIPT"

offboarding_welcome
choose_scope
cleanup_symlinks
cleanup_plugins
cleanup_fonts
restore_shell
cleanup_repos
uninstall_packages
remove_cli
offboarding_done
