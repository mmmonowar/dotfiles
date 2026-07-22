#!/bin/bash

REMOVED_SYMLINKS=()
REMOVED_PLUGINS=false
REMOVED_FONTS=false
SHELL_RESTORED=false
CLI_REMOVED=false
REPOS_REMOVED=false
PACKAGES_UNINSTALLED=false

offboarding_welcome() {
    echo -e "\n${RED}========================================="
    echo -e "  PolyTerm Offboarding"
    echo -e "=========================================${NC}"
    echo -e "This will remove PolyTerm from your system."
    echo ""
}

choose_scope() {
    echo -e "${YELLOW}What would you like to remove?${NC}"
    echo ""
    echo -e "  ${GREEN}1${NC}) PolyTerm configuration only"
    echo -e "     (symlinks, plugins, shell, CLI)"
    echo -e "     ${BLUE}~/dotfiles${NC} and ${BLUE}~/dotfiles-data${NC} will be kept"
    echo ""
    echo -e "  ${GREEN}2${NC}) Everything"
    echo -e "     (configuration + repos + data)"
    echo -e "     Full restore to pre-PolyTerm state"
    echo ""
    printf "Choose [1/2] or q to quit: "
    read -r scope_choice

    if [[ "$scope_choice" == "q" ]]; then
        echo -e "\n${YELLOW}Offboarding cancelled.${NC}"
        exit 0
    fi

    local scope
    if [[ "$scope_choice" == "2" ]]; then
        scope="everything"
    else
        scope="config"
    fi

    echo ""

    if [[ "$scope" == "everything" ]]; then
        echo -e "${RED}You selected: Everything${NC}"
        echo -e "${YELLOW}This will remove PolyTerm AND your repos and data.${NC}"
        echo ""
        printf "Remove ~/dotfiles and ~/dotfiles-data? (y/N): "
        read -r resp
        if [[ "$resp" =~ ^[yY] ]]; then
            REMOVE_REPOS=true
        fi
        echo ""
        printf "Uninstall Homebrew packages installed by PolyTerm? (y/N): "
        read -r resp
        if [[ "$resp" =~ ^[yY] ]]; then
            UNINSTALL_PACKAGES=true
        fi
    fi

    echo ""
    printf "Proceed with offboarding? (y/N): "
    read -r confirm
    if [[ ! "$confirm" =~ ^[yY] ]]; then
        echo -e "\n${YELLOW}Offboarding cancelled.${NC}"
        exit 0
    fi
    echo ""
}

cleanup_symlinks() {
    echo -e "${YELLOW}── Removing PolyTerm symlinks ─────────${NC}"

    if [ -L "$HOME/.zshrc" ]; then
        if [ -f "$HOME/.zshrc.bak" ]; then
            rm -f "$HOME/.zshrc"
            mv "$HOME/.zshrc.bak" "$HOME/.zshrc"
            echo -e "  ${GREEN}Restored original ~/.zshrc from backup.${NC}"
        else
            rm -f "$HOME/.zshrc"
            echo -e "  ${GREEN}Removed ~/.zshrc symlink.${NC}"
        fi
        REMOVED_SYMLINKS+=("~/.zshrc")
    fi

    local links=(
        "$HOME/.tmux.conf"
        "$HOME/.zsh_plugins.txt"
        "$HOME/.hledger.journal"
    )
    for link in "${links[@]}"; do
        if [ -L "$link" ]; then
            rm -f "$link"
            echo -e "  ${GREEN}Removed ${link/$HOME/\~}${NC}"
            REMOVED_SYMLINKS+=("${link/$HOME/\~}")
        fi
    done

    local dir_links=(
        "$HOME/.config/micro"
        "$HOME/.config/glow/glow.yml"
        "$HOME/.config/zellij/config.kdl"
        "$HOME/.gemini/settings.json"
    )
    for link in "${dir_links[@]}"; do
        if [ -L "$link" ]; then
            rm -f "$link"
            echo -e "  ${GREEN}Removed ${link/$HOME/\~}${NC}"
            REMOVED_SYMLINKS+=("${link/$HOME/\~}")
        fi
    done

    if [ ${#REMOVED_SYMLINKS[@]} -eq 0 ]; then
        echo -e "  ${YELLOW}No PolyTerm symlinks found.${NC}"
    fi
    echo ""
}

cleanup_plugins() {
    echo -e "${YELLOW}── Removing plugin managers ────────────${NC}"

    if [ -d "$HOME/.antidote" ]; then
        rm -rf "$HOME/.antidote"
        echo -e "  ${GREEN}Removed ~/.antidote${NC}"
        REMOVED_PLUGINS=true
    fi

    if [ -d "$HOME/.tmux" ]; then
        rm -rf "$HOME/.tmux"
        echo -e "  ${GREEN}Removed ~/.tmux (includes TPM)${NC}"
        REMOVED_PLUGINS=true
    fi

    if [ -f "$HOME/.zsh_plugins.zsh" ]; then
        rm -f "$HOME/.zsh_plugins.zsh"
        echo -e "  ${GREEN}Removed ~/.zsh_plugins.zsh${NC}"
    fi

    if [[ "$REMOVED_PLUGINS" == false ]]; then
        echo -e "  ${YELLOW}No PolyTerm plugin directories found.${NC}"
    fi
    echo ""
}

cleanup_fonts() {
    if [[ "$OS_ENV" == "mac" ]]; then
        return
    fi
    echo -e "${YELLOW}── Removing Nerd Font ──────────────────${NC}"
    local font_dir="$HOME/.local/share/fonts"
    if ls "$font_dir"/JetBrainsMono* 2>/dev/null | head -1 | grep -q .; then
        rm -f "$font_dir"/JetBrainsMono*
        if command -v fc-cache &> /dev/null; then
            fc-cache -f "$font_dir" 2>/dev/null || true
        fi
        echo -e "  ${GREEN}Removed JetBrains Mono Nerd Font.${NC}"
        REMOVED_FONTS=true
    else
        echo -e "  ${YELLOW}No Nerd Font files found.${NC}"
    fi
    echo ""
}

restore_shell() {
    echo -e "${YELLOW}── Restoring default shell ─────────────${NC}"
    local current_shell
    current_shell=$(basename "$SHELL")
    if [[ "$current_shell" == "zsh" ]]; then
        local bash_path
        bash_path=$(command -v bash)
        printf "Restore default shell to bash? (y/N): "
        read -r resp
        if [[ "$resp" =~ ^[yY] ]]; then
            if chsh -s "$bash_path" 2>/dev/null; then
                echo -e "  ${GREEN}Default shell changed to bash.${NC}"
                SHELL_RESTORED=true
            else
                echo -e "  ${YELLOW}Could not change shell (may need sudo).${NC}"
                if sudo chsh -s "$bash_path" "$USER" 2>/dev/null; then
                    echo -e "  ${GREEN}Default shell changed to bash (via sudo).${NC}"
                    SHELL_RESTORED=true
                else
                    echo -e "  ${RED}Failed to change shell. Try manually: chsh -s $(which bash)${NC}"
                fi
            fi
        else
            echo -e "  ${YELLOW}Skipped — shell remains zsh.${NC}"
        fi
    else
        echo -e "  ${YELLOW}Shell is already $current_shell (not zsh).${NC}"
    fi
    echo ""
}

cleanup_repos() {
    if [[ "$REMOVE_REPOS" != true ]]; then
        return
    fi
    echo -e "${YELLOW}── Removing PolyTerm repositories ──────${NC}"

    if [ -d "$TARGET_DIR" ]; then
        rm -rf "$TARGET_DIR"
        echo -e "  ${GREEN}Removed $TARGET_DIR${NC}"
        REPOS_REMOVED=true
    else
        echo -e "  ${YELLOW}$TARGET_DIR not found.${NC}"
    fi

    if [ -d "$DATA_DIR" ]; then
        rm -rf "$DATA_DIR"
        echo -e "  ${GREEN}Removed $DATA_DIR${NC}"
        REPOS_REMOVED=true
    else
        echo -e "  ${YELLOW}$DATA_DIR not found.${NC}"
    fi

    if [ -f "$HOME/.zshrc.polyterm" ]; then
        rm -f "$HOME/.zshrc.polyterm"
        echo -e "  ${GREEN}Removed ~/.zshrc.polyterm backup.${NC}"
    fi

    echo ""
}

uninstall_packages() {
    if [[ "$UNINSTALL_PACKAGES" != true ]]; then
        return
    fi
    echo -e "${YELLOW}── Uninstalling PolyTerm packages ─────${NC}"

    local brew_core_path="$TARGET_DIR/OS/$OS_ENV/Brewfile.core"
    if [[ -f "$TARGET_DIR/OS/$OS_ENV/$device_id/Brewfile.core" ]]; then
        brew_core_path="$TARGET_DIR/OS/$OS_ENV/$device_id/Brewfile.core"
    fi

    if [ -f "$brew_core_path" ]; then
        echo -e "  Uninstalling core packages..."
        brew bundle --file="$brew_core_path" --cleanup 2>/dev/null || true
        echo -e "  ${GREEN}Core packages uninstalled.${NC}"
        PACKAGES_UNINSTALLED=true
    else
        echo -e "  ${YELLOW}No Brewfile.core found at $brew_core_path.${NC}"
    fi

    local brew_apps_path="$TARGET_DIR/OS/$OS_ENV/Brewfile.apps"
    if [[ -f "$TARGET_DIR/OS/$OS_ENV/$device_id/Brewfile.apps" ]]; then
        brew_apps_path="$TARGET_DIR/OS/$OS_ENV/$device_id/Brewfile.apps"
    fi

    if [ -f "$brew_apps_path" ]; then
        echo -e "  Uninstalling optional app packages..."
        brew bundle --file="$brew_apps_path" --cleanup 2>/dev/null || true
        echo -e "  ${GREEN}App packages uninstalled.${NC}"
        PACKAGES_UNINSTALLED=true
    else
        echo -e "  ${YELLOW}No Brewfile.apps found at $brew_apps_path.${NC}"
    fi

    if [[ "$PACKAGES_UNINSTALLED" == false ]]; then
        echo -e "  ${YELLOW}No Brewfiles found. Skipping package uninstall.${NC}"
    fi
    echo ""
}

remove_cli() {
    echo -e "${YELLOW}── Removing polyterm CLI ───────────────${NC}"
    local polyterm_path
    polyterm_path=$(command -v polyterm 2>/dev/null)
    if [ -n "$polyterm_path" ]; then
        printf "Remove polyterm CLI from ${polyterm_path}? (y/N): "
        read -r resp
        if [[ "$resp" =~ ^[yY] ]]; then
            rm -f "$polyterm_path"
            echo -e "  ${GREEN}Removed $polyterm_path${NC}"
            CLI_REMOVED=true
        else
            echo -e "  ${YELLOW}Skipped.${NC}"
        fi
    else
        echo -e "  ${YELLOW}polyterm CLI not found in PATH.${NC}"
    fi
    echo ""
}

offboarding_done() {
    echo -e "${GREEN}========================================="
    echo -e "  Offboarding Complete"
    echo -e "=========================================${NC}"
    echo ""
    echo -e "  ${BLUE}Removed:${NC}"
    for link in "${REMOVED_SYMLINKS[@]}"; do
        echo -e "    - $link"
    done
    [[ "$REMOVED_PLUGINS" == true ]] && echo -e "    - Plugin managers (~/.antidote, ~/.tmux)"
    [[ "$REMOVED_FONTS" == true ]] && echo -e "    - JetBrains Mono Nerd Font"
    [[ "$SHELL_RESTORED" == true ]] && echo -e "    - Default shell restored to bash"
    [[ "$CLI_REMOVED" == true ]] && echo -e "    - polyterm CLI"
    [[ "$REPOS_REMOVED" == true ]] && echo -e "    - ~/dotfiles and ~/dotfiles-data"
    [[ "$PACKAGES_UNINSTALLED" == true ]] && echo -e "    - Homebrew packages"
    echo ""
    echo -e "  ${YELLOW}Next steps:${NC}"
    echo -e "    Restart your terminal or run: ${GREEN}exec bash${NC}"
    echo ""
}
