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
    echo -e "  ${GREEN}1${NC}) tmux    — Auto-start Tmux Dashboard on terminal open"
    echo -e "  ${GREEN}2${NC}) zellij  — Auto-start Zellij on terminal open"
    echo -e "  ${GREEN}3${NC}) none    — Start multiplexer manually (zsh prompt only)"
    echo ""
    printf "Choose [1/2/3] (default: none): "
    read -r mux_choice

    local value="none"
    if [[ "$mux_choice" == "1" || "$mux_choice" == "tmux" ]]; then
        value="tmux"
    elif [[ "$mux_choice" == "2" || "$mux_choice" == "zellij" ]]; then
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
        echo -e "${GREEN}✅  Tmux selected — will auto-start on terminal open.${NC}"
    elif [[ "$value" == "zellij" ]]; then
        echo -e "${GREEN}✅  Zellij selected — will auto-start on terminal open.${NC}"
    else
        echo -e "${GREEN}✅  No auto-start — type 'tmux' or 'zellij' manually when needed.${NC}"
    fi
}

choose_apps() {
    echo -e "\n${YELLOW}── Optional Applications ────────────────${NC}"

    local brew_apps_path="${DOTFILES_ROOT}/OS/${OS_ENV}/Brewfile.apps"
    local device_apps_path="${DOTFILES_ROOT}/OS/${OS_ENV}/${device_id}/Brewfile.apps"
    [[ -f "$device_apps_path" ]] && brew_apps_path="$device_apps_path"

    if [ ! -f "$brew_apps_path" ]; then
        echo -e "${YELLOW}No optional apps file found for ${OS_ENV}. Skipping.${NC}"
        return
    fi

    echo -e "Pick additional tools to install."
    echo -e "Use ${GREEN}TAB${NC} to select multiple, ${GREEN}ENTER${NC} to confirm, ${GREEN}ESC${NC} to skip."
    echo ""

    if command -v fzf &> /dev/null; then
        local apps=()
        while IFS= read -r app; do
            apps+=("$app")
        done < <(grep -E '^(brew|cask|vscode)' "$brew_apps_path" | sed -E 's/^(brew|cask|vscode) "([^"]+)".*/\1: \2/')

        if [ ${#apps[@]} -eq 0 ]; then
            echo -e "${YELLOW}No installable entries found in Brewfile.apps.${NC}"
            return
        fi

        local selected
        selected=$(printf "%s\n" "${apps[@]}" | fzf --multi --header "Select Optional Apps" --reverse --border rounded)

        if [ -n "$selected" ]; then
            local tmpfile
            tmpfile=$(mktemp)
            echo -e "📝  ${BLUE}Preparing selected apps...${NC}"
            while read -r line; do
                local type name
                type=$(echo "$line" | cut -d: -f1)
                name=$(echo "$line" | cut -d: -f2 | xargs)
                grep "^$type \"$name\"" "$brew_apps_path" >> "$tmpfile"
            done <<< "$selected"

            echo -e "📦  ${BLUE}Installing selected apps...${NC}"
            brew bundle --verbose --file="$tmpfile"
            rm "$tmpfile"
        else
            echo -e "⏭️  ${YELLOW}No apps selected. Skipping.${NC}"
        fi
    else
        printf "Install all optional apps? (y/N): "
        read -r resp
        if [[ "$resp" =~ ^[yY] ]]; then
            brew bundle --verbose --file="$brew_apps_path"
        fi
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
