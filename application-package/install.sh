#!/bin/bash

# ==========================================
# 🚀  DOTFILES INSTALLER
# ==========================================
# This script installs the dotfiles repository and configures the environment.
# Support: macOS, WSL (Ubuntu), and generic Linux.
# Usage: bash -c "$(curl -fsSL https://raw.githubusercontent.com/mmmonowar/dotfiles/main/application-package/install.sh)"
# ==========================================

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}=========================================="
echo -e "📦  Starting Dotfiles Installation"
echo -e "==========================================${NC}"

# 1. Variables
# Detect if we are already inside the dotfiles repository
if [ -d ".git" ] && git remote -v | grep -q "mmmonowar/dotfiles"; then
    TARGET_DIR=$(pwd)
    echo -e "📍  ${BLUE}Detected existing repository at $TARGET_DIR${NC}"
else
    TARGET_DIR="$HOME/dotfiles"
fi
REPO_URL="${POLYTERM_URL_DOTFILES_REPO:-"https://github.com/mmmonowar/dotfiles.git"}"

# 2. OS Detection
if [[ "$OSTYPE" == "darwin"* ]]; then
    OS_ENV="mac"
    OS_ZSHRC="zshrc"
elif uname -a | grep -iq "microsoft\|wsl"; then
    OS_ENV="wsl"
    OS_ZSHRC="zshrc"
else
    OS_ENV="linux"
    OS_ZSHRC="zshrc"
fi

echo -e "🖥️  Detected OS: ${GREEN}$OS_ENV${NC}"

# 3. Pre-requisites: Homebrew
if ! command -v brew &> /dev/null; then
    echo -e "🍺  ${BLUE}Installing Homebrew...${NC}"
    /bin/bash -c "$(curl -fsSL "${POLYTERM_URL_HOMEBREW_INSTALLER:-"https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh"}")"
    
    # Set up brew shellenv for the rest of the script
    if [[ "$OS_ENV" == "mac" ]]; then
        if [[ -f "/opt/homebrew/bin/brew" ]]; then
            eval "$(/opt/homebrew/bin/brew shellenv)"
        else
            eval "$(/usr/local/bin/brew shellenv)"
        fi
    else
        eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
    fi
else
    echo -e "✅  ${GREEN}Homebrew is already installed.${NC}"
fi

# 4. Clone Repository
if [ ! -d "$TARGET_DIR" ]; then
    echo -e "📥  ${BLUE}Cloning repository to $TARGET_DIR...${NC}"
    git clone "$REPO_URL" "$TARGET_DIR"
else
    echo -e "✅  ${GREEN}Repository already exists at $TARGET_DIR.${NC}"
    echo -e "🔄  ${BLUE}Updating repository...${NC}"
    cd "$TARGET_DIR" && git pull origin main && cd - > /dev/null
fi

# 4.5. Initialize dotfiles-data (private data repo)
DATA_DIR="$TARGET_DIR/../dotfiles-data"
if [ ! -d "$DATA_DIR" ]; then
    echo -e "📁  ${BLUE}Creating dotfiles-data directory at $DATA_DIR...${NC}"
    mkdir -p "$DATA_DIR"
    cd "$DATA_DIR" && git init && cd "$TARGET_DIR"
    mkdir -p "$DATA_DIR/settings"
    mkdir -p "$DATA_DIR/cache/OS/mac" "$DATA_DIR/cache/OS/wsl" "$DATA_DIR/cache/OS/linux"
    mkdir -p "$DATA_DIR/editor/buffers"
    mkdir -p "$DATA_DIR/scratchpad"
    mkdir -p "$DATA_DIR/hledger"
    echo -e "✅  ${GREEN}dotfiles-data initialized at $DATA_DIR${NC}"
    echo -e "💡  ${YELLOW}To sync data across machines, push this repo to a private remote:${NC}"
    echo -e "    cd $DATA_DIR && git remote add origin <your-private-repo-url> && git push -u origin main"
else
    echo -e "✅  ${GREEN}dotfiles-data already exists at $DATA_DIR.${NC}"
fi
export DOTFILES_DATA="$DATA_DIR"

# Source settings to get URLs
if [ -f "$DATA_DIR/settings/.polyterm_settings" ]; then
    source "$DATA_DIR/settings/.polyterm_settings"
fi

# 5. Backup & Symlink Configuration Files
echo -e "🔗  ${BLUE}Setting up symbolic links...${NC}"

function safe_link() {
    local src="$1"
    local dest="$2"
    
    # Ensure source exists
    if [ ! -e "$src" ]; then
        echo -e "${RED}❌ Error: Source file $src does not exist.${NC}"
        return 1
    fi

    # Handle existing destination
    if [ -e "$dest" ] || [ -L "$dest" ]; then
        if [ -L "$dest" ]; then
            # If it's a symlink, just remove it
            rm "$dest"
        else
            # If it's a real file/dir, back it up
            echo -e "💾  ${YELLOW}Backing up $dest to $dest.bak${NC}"
            mv "$dest" "$dest.bak"
        fi
    fi
    
    ln -sf "$src" "$dest"
    echo -e "✅  Linked ${BLUE}$dest${NC} -> ${GREEN}$src${NC}"
}

# Generate device identifier for optional device-specific overrides
device_id=$(hostname | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9_-]//g')

# Symlink .zshrc (support device override if present)
zshrc_src="$TARGET_DIR/OS/$OS_ENV/$OS_ZSHRC"
if [[ -f "$TARGET_DIR/OS/$OS_ENV/$device_id/$OS_ZSHRC" ]]; then
    zshrc_src="$TARGET_DIR/OS/$OS_ENV/$device_id/$OS_ZSHRC"
fi
safe_link "$zshrc_src" "$HOME/.zshrc"

# Symlink .tmux.conf
safe_link "$TARGET_DIR/common/config/tmux/tmux.conf" "$HOME/.tmux.conf"

# Symlink micro config directory
mkdir -p "$HOME/.config"
safe_link "$TARGET_DIR/common/config/micro" "$HOME/.config/micro"

# Symlink gemini settings
mkdir -p "$HOME/.gemini"
safe_link "$TARGET_DIR/common/config/gemini/settings.json" "$HOME/.gemini/settings.json"

# Symlink glow config
mkdir -p "$HOME/.config/glow"
safe_link "$TARGET_DIR/common/config/glow/glow.yml" "$HOME/.config/glow/glow.yml"

# Symlink antidote plugin list
safe_link "$TARGET_DIR/common/config/zsh/plugins.txt" "$HOME/.zsh_plugins.txt"

# Symlink zellij config
mkdir -p "$HOME/.config/zellij"
safe_link "$TARGET_DIR/common/config/zellij/config.kdl" "$HOME/.config/zellij/config.kdl"

# 6. Install Packages (Brewfile)
brew_core_path="$TARGET_DIR/OS/$OS_ENV/Brewfile.core"
if [[ -f "$TARGET_DIR/OS/$OS_ENV/$device_id/Brewfile.core" ]]; then
    brew_core_path="$TARGET_DIR/OS/$OS_ENV/$device_id/Brewfile.core"
fi

echo -e "📦  ${BLUE}Installing CORE packages from $brew_core_path...${NC}"
brew bundle --verbose --file="$brew_core_path"

# Interactive App Selection
echo -e "\n🧩  ${BLUE}Optional Applications Selection${NC}"
brew_apps_path="$TARGET_DIR/OS/$OS_ENV/Brewfile.apps"
if [[ -f "$TARGET_DIR/OS/$OS_ENV/$device_id/Brewfile.apps" ]]; then
    brew_apps_path="$TARGET_DIR/OS/$OS_ENV/$device_id/Brewfile.apps"
fi
APPS_FILE="$brew_apps_path"


if [ -f "$APPS_FILE" ]; then
    echo -e "You can now choose which optional apps to install."
    
    # Use fzf if available (it should be, as it is in core)
    if command -v fzf &> /dev/null; then
        # Parse Brewfile.apps to get clean names for selection
        # Supports: brew "name", cask "name", vscode "name"
        all_apps=()
        while IFS= read -r app; do
            all_apps+=("$app")
        done < <(grep -E '^(brew|cask|vscode)' "$APPS_FILE" | sed -E 's/^(brew|cask|vscode) "([^"]+)".*/\1: \2/')
        
        if [ ${#all_apps[@]} -gt 0 ]; then
            echo -e "${YELLOW}Instructions: Use TAB to select multiple, ENTER to confirm, ESC to skip all.${NC}"
            selected=$(printf "%s\n" "${all_apps[@]}" | fzf --multi --header "Select Optional Apps to Install" --reverse --border rounded)
            
            if [ -n "$selected" ]; then
                TEMP_BREWFILE=$(mktemp)
                echo -e "📝  ${BLUE}Generating temporary Brewfile for selected apps...${NC}"
                
                while read -r line; do
                    type=$(echo "$line" | cut -d: -f1)
                    name=$(echo "$line" | cut -d: -f2 | xargs)
                    grep "^$type \"$name\"" "$APPS_FILE" >> "$TEMP_BREWFILE"
                done <<< "$selected"
                
                echo -e "📦  ${BLUE}Installing selected apps...${NC}"
                brew bundle --verbose --file="$TEMP_BREWFILE"
                rm "$TEMP_BREWFILE"
            else
                echo -e "⏭️  ${YELLOW}No optional apps selected. Skipping.${NC}"
            fi
        fi
    else
        # Fallback for systems without fzf (though it should be in core)
        printf "Install all optional apps from %s/Brewfile.apps? (y/N): " "$OS_ENV"
        read -r resp
        if [[ "$resp" =~ ^[yY] ]]; then
            brew bundle --verbose --file="$APPS_FILE"
        fi
    fi
else
    echo -e "⏭️  ${YELLOW}No optional apps file found. Skipping.${NC}"
fi

# 6.5. Dependency Verification
echo -e "\n🔍  ${BLUE}Verifying installed dependencies...${NC}"
check_deps() {
    local deps=("python3" "fzf" "git" "tmux" "zsh" "gh" "shellcheck")
    local all_ok=true
    for dep in "${deps[@]}"; do
        if command -v "$dep" &>/dev/null; then
            echo -e "  ${GREEN}✅ $dep${NC} → $(command -v "$dep")"
        else
            echo -e "  ${RED}❌ $dep${NC} → NOT FOUND"
            all_ok=false
        fi
    done
    if [ "$all_ok" = false ]; then
        echo -e "\n${YELLOW}⚠️  Some core dependencies are missing. Run 'polyterm setup' again or install manually.${NC}"
    else
        echo -e "  ${GREEN}All core dependencies are available.${NC}"
    fi
}
check_deps

# 7. Install TPM (Tmux Plugin Manager)
if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
    echo -e "🔌  ${BLUE}Installing TPM (Tmux Plugin Manager)...${NC}"
    mkdir -p "$HOME/.tmux/plugins"
    git clone "${POLYTERM_URL_TPM_REPO:-"https://github.com/tmux-plugins/tpm"}" "$HOME/.tmux/plugins/tpm"
else
    echo -e "✅  ${GREEN}TPM is already installed.${NC}"
fi

# 7.5 Install Antidote (Zsh Plugin Manager)
if [ ! -d "$HOME/.antidote" ]; then
    echo -e "🔌  ${BLUE}Installing Antidote Zsh Plugin Manager...${NC}"
    git clone --depth=1 "${POLYTERM_URL_ANTIDOTE_REPO:-"https://github.com/mattmc3/antidote.git"}" "$HOME/.antidote"
else
    echo -e "✅  ${GREEN}Antidote is already installed.${NC}"
fi

# 8. Install Nerd Font (Linux/WSL only, Mac uses Brew Cask)
if [[ "$OS_ENV" != "mac" ]]; then
    # Check if font exists (JetBrains Mono)
    if ! (fc-list 2>/dev/null | grep -qi "JetBrainsMono") ; then
        echo -e "🔡  ${BLUE}Installing JetBrains Mono Nerd Font...${NC}"
        FONT_DIR="$HOME/.local/share/fonts"
        mkdir -p "$FONT_DIR"
        # Download the font
        curl -fLo "$FONT_DIR/JetBrainsMono.zip" "${POLYTERM_URL_NERDFONT_JETBRAINS:-"https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip"}"
        unzip -o "$FONT_DIR/JetBrainsMono.zip" -d "$FONT_DIR"
        rm "$FONT_DIR/JetBrainsMono.zip"
        # Update font cache
        if command -v fc-cache &> /dev/null; then
            fc-cache -f "$FONT_DIR"
        fi
        echo -e "✅  ${GREEN}Nerd Font installed.${NC}"
    else
        echo -e "✅  ${GREEN}Nerd Font already detected.${NC}"
    fi
fi

# 9. Shell Configuration
current_shell=$(basename "$SHELL")
if [[ "$current_shell" != "zsh" ]]; then
    echo -e "\n${YELLOW}Prompt: Current shell is $current_shell.${NC}"
    printf "Do you want to change your default shell to Zsh? (y/N): "
    read -r resp
    if [[ "$resp" =~ ^[yY] ]]; then
        zsh_path=$(which zsh)
        echo -e "🐚  ${BLUE}Changing shell to $zsh_path...${NC}"
        # Some systems might need sudo for chsh
        if ! chsh -s "$zsh_path" 2>/dev/null; then
            echo -e "${YELLOW}Need sudo to change shell...${NC}"
            sudo chsh -s "$zsh_path" "$USER"
        fi
    fi
fi

# 9.5 Register/Update Device Info
echo -e "\n🔄  ${BLUE}Registering device details in device-list.yml...${NC}"
if [ -f "$TARGET_DIR/common/palette/update_device.py" ]; then
    python3 "$TARGET_DIR/common/palette/update_device.py" "$DATA_DIR"
fi

# 10. Security Scan
echo -e "\n🛡️  ${BLUE}Performing initial security scan...${NC}"
if [ -f "$TARGET_DIR/common/palette/security.sh" ]; then
    # Set DOTFILES_ROOT for the scan
    export DOTFILES_ROOT="$TARGET_DIR"
    export DOTFILES_DATA="$DATA_DIR"
    source "$TARGET_DIR/common/palette/security.sh"
    dot-scan
fi

echo -e "\n${GREEN}=========================================="
echo -e "✨  Installation Complete!"
echo -e "==========================================${NC}"
echo -e "To finalize the setup:"
echo -e "1. Restart your terminal or run: ${BLUE}source ~/.zshrc${NC}"
echo -e "2. In Tmux, press ${BLUE}Alt+I${NC} (capital I) to install plugins."
echo -e "3. Use ${BLUE}Alt+P${NC} to open the Command Palette in Tmux or Zellij."

