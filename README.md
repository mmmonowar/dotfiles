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

## 📦 Package Tiers

PolyTerm installs packages in three tiers:

| Tier | What | How | Examples |
|---|---|---|---|
| **1 — Core** (Brewfile.core) | Required for PolyTerm to function | Auto-installed, no prompt | `fzf`, `git`, `tmux`, `zsh` |
| **2 — App Dependencies** | Required for specific PolyTerm features | Auto-installed during onboarding | `micro` (Scratchpad), `btop` (Dashboard), `glow` (Docs viewer) |
| **3 — Optional** (Brewfile.apps) | Extra tools of your choice | Interactive fzf picker during onboarding | `lazygit`, `bat`, `emacs`, `rust` |

## 🔧 Troubleshooting

### macOS Alt/Option Keys

If `Alt+P` (Command Palette) produces a character like `π` instead of opening the palette:

- **Local terminal**: The first-run onboarding wizard automatically detects your terminal (Terminal.app or iTerm2) and configures the Option key as Meta.
- **SSH session**: Terminal detection may fall back to applying both fixes. Open a new terminal window on the host machine for changes to take effect.
- **Manual fix**: Run `polyterm palette` → Fix Alt Keys, or configure your terminal:
  - **Terminal.app**: Settings → Profiles → Keyboard → Check "Use Option as Meta key"
  - **iTerm2**: Settings → Profiles → Keys → Left Option key → Esc+

### Quick Exit from Tmux/Zellij

Use `polyterm quit` to kill the current multiplexer session:
- Inside **Tmux**: kills the current session, returns to parent shell
- Inside **Zellij**: quits Zellij, returns to parent shell
- Outside both: prints "Not inside a Tmux or Zellij session."

## 📖 Documentation
For detailed usage instructions, keybindings, and troubleshooting, see the **[User Manual](https://github.com/mmmonowar/dotfiles-projectmanager/blob/main/project-manager/80%20Manuals/user-manual.md)**.
