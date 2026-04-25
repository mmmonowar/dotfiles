# 📖 PolyTerm User Manual

Welcome to **PolyTerm**, a high-fidelity, cross-platform terminal environment optimized for macOS, WSL, and Linux. This guide covers installation, daily usage, and advanced features.

---

## 🚀 Installation & Setup

PolyTerm can be installed on any supported system using a single command.

### Method 1: Homebrew Tap (Recommended)
This installs the `polyterm` CLI globally, providing the cleanest management experience.
```bash
brew tap mmmonowar/dotfiles https://github.com/mmmonowar/dotfiles
brew install polyterm
polyterm setup
```

### Method 2: Remote Bootstrap
Ideal for fresh systems where Homebrew might not yet be configured.
```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/mmmonowar/dotfiles/main/application-package/install.sh)"
```

---

## 🛠️ The `polyterm` CLI

The `polyterm` command is your central hub for environment management.

| Command | Description |
| :--- | :--- |
| `polyterm` | Launches the Command Palette (default) |
| `polyterm setup` | Initializes the dotfiles, backups, and symlinks |
| `polyterm sync` | Dumps local `Brewfile`, commits, and pushes to GitHub |
| `polyterm pull` | Fetches updates from GitHub and installs new dependencies |
| `polyterm reload` | Instantly refreshes Zsh and Tmux configurations |
| `polyterm help` | Displays available commands |

---

## 🎛️ Unified Command Palette (`Alt+p`)

The heart of PolyTerm is the **Command Palette**, a VSCode-style interactive menu triggered via `Alt+p` (or `Meta+p`) inside Tmux.

### Features:
- **Launch App**: Search and launch CLI tools defined in your Brewfile with dynamic descriptions.
- **Install/Uninstall**: Add or remove Homebrew packages with automatic GitHub synchronization.
- **Execute Shortcut**: Trigger complex Tmux window/pane operations via a menu.
- **Maintenance**: Access `dot-sync`, `dot-pull`, and environment reloading in one click.
- **Alt-Key Fix**: A built-in utility to diagnose and fix keyboard shortcut issues.

---

## 🗖 Tmux Shortcuts & Navigation

PolyTerm uses standardized `Alt` (Meta) keybindings for a consistent experience across all platforms.

### Window & Session Management
- **`Alt+m`**: New Window
- **`Alt+e`**: Kill Window
- **`Alt+Up` / `Alt+Down`**: Cycle Windows
- **`Alt+,`**: New Session
- **`Alt+0`**: Cycle Sessions
- **`Alt+w`**: Kill Session

### Pane Management (2x2 Focus Grid)
- **`Alt+1`**: Create/Split Pane (Maximum 4 per window)
- **`Alt+2`**: Close/Kill Pane
- **`Alt+Left` / `Alt+Right`**: Cycle Panes

### System & Navigation
- **`Alt+p`**: Open Command Palette
- **`Alt+r`**: Reload Configuration (`dot-reload`)

---

## 🐚 Shell Features (Zsh)

- **Automated Cockpit**: Terminal launch automatically switches to Zsh and initializes a Tmux "default" session.
- **Smart Dashboard**: A dedicated `Dashboard` session starts with `btop` and `docker ps` on launch.
- **`search <query>`**: Instant DuckDuckGo search from the command line via `ddgr`.
- **`dot-sync`**: Automated workflow that runs `brew bundle dump`, git adds, commits with a timestamp, and pushes.
- **`dot-pull`**: Automated workflow that pulls latest changes and runs `brew bundle` to stay in sync.

---

## 📝 Micro Editor & PolyMark

PolyTerm includes a customized **Micro** editor configuration located in `common/micro`.
- **Syntax**: Features the custom **PolyMark** syntax highlighting.
- **Theme**: Uses the `PolyMark.micro` colorscheme for a high-contrast, aesthetic editing experience.
- **Deployment**: Configurations are automatically symlinked to `~/.config/micro`.

---

## 🛠️ Troubleshooting

### Alt/Option Keys Not Working
If `Alt+p` or other shortcuts fail:
1.  **WSL/Linux**: Run the "Fix Alt Keys" option in the Command Palette or execute `polyterm palette` -> `Fix Alt Keys`.
2.  **macOS (iTerm2)**: Go to `Settings` -> `Profiles` -> `Keys` and set `Left Option key` to `Esc+`.
3.  **macOS (Terminal.app)**: Go to `Settings` -> `Profiles` -> `Keyboard` and check `Use Option as Meta key`.

### Monochrome Display
If the terminal lacks color:
- Ensure your terminal emulator supports **TrueColor (24-bit)**.
- PolyTerm automatically exports `COLORTERM=truecolor` and `MICRO_TRUECOLOR=1` in your `.zshrc`.
