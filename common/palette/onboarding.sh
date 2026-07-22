#!/bin/bash

# ==========================================
# 🎉  POLYTERM ONBOARDING WIZARD
# ==========================================
# Runs once at the end of install.sh to let the
# user configure their environment interactively.

SETTINGS_FILE="${DOTFILES_DATA}/settings/.polyterm_settings"

onboarding_welcome() {
    echo -e "\n${BLUE}========================================="
    echo -e "🎉  Welcome to PolyTerm!"
    echo -e "=========================================${NC}"
    echo -e "Your new terminal environment is ready."
    echo -e "Let's configure a few things to get started."
}

choose_multiplexer() {
    echo -e "\n${YELLOW}── Multiplexer ───────────────────────────${NC}"
    echo -e "PolyTerm works with both Tmux and Zellij."
    echo -e "Both offer the same Command Palette (Alt+P)"
    echo -e "and keybindings."
    echo ""
    echo -e "  ${GREEN}1${NC}) tmux    — Dashboard session with auto-start"
    echo -e "  ${GREEN}2${NC}) zellij  — Dev layout with auto-attach"
    echo ""
    printf "Choose [1/2] (default: tmux): "
    read -r mux_choice

    local value="tmux"
    if [[ "$mux_choice" == "2" || "$mux_choice" == "zellij" ]]; then
        value="zellij"
    fi

    if grep -q "^export POLYTERM_MULTIPLEXER=" "$SETTINGS_FILE" 2>/dev/null; then
        if [[ "$OS_ENV" == "mac" ]]; then
            sed -i '' "s|^export POLYTERM_MULTIPLEXER=.*|export POLYTERM_MULTIPLEXER=\"$value\"|" "$SETTINGS_FILE"
        else
            sed -i "s|^export POLYTERM_MULTIPLEXER=.*|export POLYTERM_MULTIPLEXER=\"$value\"|" "$SETTINGS_FILE"
        fi
    else
        echo "export POLYTERM_MULTIPLEXER=\"$value\"" >> "$SETTINGS_FILE"
    fi

    if [[ "$value" == "tmux" ]]; then
        echo -e "${GREEN}✅  Tmux selected.${NC}"
    else
        echo -e "${GREEN}✅  Zellij selected.${NC}"
    fi
}

configure_alt_keys() {
    echo -e "\n${YELLOW}── Alt/Option Key Setup ───────────────────${NC}"

    if [[ "$OS_ENV" == "mac" ]]; then
        echo -e "${YELLOW}On macOS, you need to configure your terminal${NC}"
        echo -e "${YELLOW}to send Alt/Option as Meta:${NC}"
        echo ""
        echo -e "  ${GREEN}iTerm2${NC}:"
        echo -e "    Settings → Profiles → Keys →"
        echo -e "    Left Option Key → ${GREEN}Esc+${NC}"
        echo ""
        echo -e "  ${GREEN}Terminal.app${NC}:"
        echo -e "    Settings → Profiles → Keyboard →"
        echo -e "    Check ${GREEN}\"Use Option as Meta key\"${NC}"
        echo ""

    elif [[ "$OS_ENV" == "linux" ]]; then
        local distro=""
        if command -v gsettings &> /dev/null; then
            if gsettings get org.gnome.Terminal.Legacy.Settings menu-accelerator-enabled 2>/dev/null | grep -q "true"; then
                printf "Disable GNOME Terminal menu accelerators (so Alt bindings work)? (Y/n): "
                read -r resp
                if [[ ! "$resp" =~ ^[nN] ]]; then
                    gsettings set org.gnome.Terminal.Legacy.Settings menu-accelerator-enabled false
                    echo -e "${GREEN}✅  Menu accelerators disabled.${NC}"
                fi
            else
                echo -e "${GREEN}✅  Alt keys already configured.${NC}"
            fi
        else
            echo -e "${YELLOW}GNOME Terminal not detected — no changes needed.${NC}"
        fi

    elif [[ "$OS_ENV" == "wsl" ]]; then
        echo -e "${YELLOW}If Alt bindings don't work in Windows Terminal,${NC}"
        echo -e "${YELLOW}check for conflicting Alt shortcuts in:${NC}"
        echo -e "  Settings → Actions → (search for Alt)"
        echo ""
    fi
}

onboarding_done() {
    echo ""
    echo -e "${GREEN}========================================="
    echo -e "✨  All set!"
    echo -e "=========================================${NC}"
    echo -e "Next steps:"
    echo -e "  1. ${BLUE}Restart your terminal${NC} or run: ${GREEN}source ~/.zshrc${NC}"
    echo -e "  2. Press ${GREEN}Alt+P${NC} to open the Command Palette"
    echo -e "  3. In Tmux, press ${GREEN}Alt+I${NC} to install plugins"
}
