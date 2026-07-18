# 🚀 PolyTerm

**PolyTerm** is a high-fidelity, cross-platform dotfiles environment for macOS, WSL, and Linux. It provides a unified, GUI-like terminal experience using Zsh, Tmux, and a custom Command Palette.

## ✨ Highlights
- **One-Command Install**: Setup your entire environment in seconds.
- **Unified Command Palette**: `Alt+p` to launch apps, manage packages, and execute shortcuts.
- **Self-Healing Sync**: `dot-sync` automatically repairs your environment by installing missing dependencies.
- **Auto-Updating Agent**: Gemini CLI stays up-to-date automatically in the background.
- **Cross-Platform**: Seamlessly transition between Mac and Linux with consistent keybindings.
- **Declarative**: All packages managed via Homebrew Brewfiles.
- **Dynamic Theme System**: Switch between Peppermint, Catppuccin Mocha, Tokyo Night, or create custom themes via the palette.

## 📦 Quick Start

### Install via Homebrew
```bash
brew tap mmmonowar/dotfiles https://github.com/mmmonowar/dotfiles
brew install polyterm
polyterm setup
```

### Install via Curl
```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/mmmonowar/dotfiles/main/application-package/install.sh)"
```

## 📖 Documentation
For detailed usage instructions, keybindings, and troubleshooting, see the **[User Manual](https://github.com/mmmonowar/dotfiles-projectmanager/blob/main/project-manager/80%20Manuals/user-manual.md)**.
