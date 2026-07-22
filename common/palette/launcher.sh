#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

ensure_brew_env() {
    if command -v brew &>/dev/null; then
        return 0
    fi
    if [[ -f "/opt/homebrew/bin/brew" ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    elif [[ -f "/usr/local/bin/brew" ]]; then
        eval "$(/usr/local/bin/brew shellenv)"
    elif [[ -f "/home/linuxbrew/.linuxbrew/bin/brew" ]]; then
        eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
    else
        return 1
    fi
}

ensure_multiplexer() {
    local name="$1"
    if command -v "$name" &>/dev/null; then
        return 0
    fi

    echo -e "${YELLOW}$name is not installed.${NC}"
    printf "Install $name via Homebrew? (Y/n): "
    read -r resp
    if [[ "$resp" =~ ^[nN] ]]; then
        echo -e "${RED}Cannot continue without $name. Exiting.${NC}"
        exit 1
    fi

    if ! ensure_brew_env; then
        echo -e "${YELLOW}Homebrew is not installed. Installing...${NC}"
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        ensure_brew_env
    fi

    echo -e "📦  ${BLUE}Installing $name...${NC}"
    brew install "$name"
    echo -e "${GREEN}$name installed.${NC}"
}

start_multiplexer() {
    local name="$1"
    echo -e "🚀  ${GREEN}Starting $name...${NC}"
    if [[ "$name" == "tmux" ]]; then
        tmux new-session -A -s default
    elif [[ "$name" == "zellij" ]]; then
        zellij attach -c default
    fi
}

case "${1:-}" in
    tmux|zellij)
        ensure_multiplexer "$1"
        start_multiplexer "$1"
        ;;
    interactive|"")
        echo -e "${BLUE}── PolyTerm Launcher ───────────────────${NC}"
        echo ""
        echo -e "  ${GREEN}1${NC}) Tmux"
        echo -e "  ${GREEN}2${NC}) Zellij"
        echo -e "  ${GREEN}q${NC}) Cancel"
        echo ""
        printf "Choose: "
        read -r choice
        case "$choice" in
            1|tmux)
                ensure_multiplexer "tmux"
                start_multiplexer "tmux"
                ;;
            2|zellij)
                ensure_multiplexer "zellij"
                start_multiplexer "zellij"
                ;;
            q|Q)
                echo -e "${YELLOW}Cancelled.${NC}"
                exit 0
                ;;
            *)
                echo -e "${RED}Invalid choice.${NC}"
                exit 1
                ;;
        esac
        ;;
    *)
        echo -e "${RED}Usage: launcher.sh [tmux|zellij|interactive]${NC}"
        exit 1
        ;;
esac
