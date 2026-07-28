# 📖 PolyTerm User Manual

> [!NOTE]
> **Cross-Repo References**: This is a documentation-only companion to [mmmonowar/dotfiles](https://github.com/mmmonowar/dotfiles). File paths (e.g., `common/`, `OS/`, `bin/`) and installation commands (e.g., `brew tap`, `curl`) reference the parent `dotfiles` repo — not this one.

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

### WSL (Fresh Install)
```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/mmmonowar/dotfiles/main/bin/bootstrap-wsl)"
```
Installs system packages, Homebrew, and polyterm in one shot. Then runs full setup.

### WSL (Homebrew Already Installed)
```bash
brew update && brew install polyterm && polyterm setup
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
| `polyterm reload` | Opens interactive reload menu to select which configs to refresh |
| `polyterm reload --all` | Reload all configs non-interactively |
| `polyterm reload --shell` | Reload only shell configs (zshrc, bashrc) |
| `polyterm reload --settings` | Reload only PolyTerm settings |
| `polyterm reload --mux-config` | Reload only multiplexer configuration |
| `polyterm reload --mux-restart` | Restart multiplexer only |
| `polyterm help` | Displays available commands |

> **Maintenance**: For install, update, reinstall, repair, and uninstall commands, see the [Common Operations](https://github.com/mmmonowar/dotfiles#%EF%B8%8F-common-operations) section in the README.

---

## 🎛️ Unified Command Palette (`Ctrl+Shift+P`)

The heart of PolyTerm is the **Command Palette**, a VSCode-style interactive menu triggered via `Ctrl+Shift+P` inside Tmux/Zellij.

### Features:
- **Launch App**: Search and launch CLI tools defined in your Brewfile with dynamic descriptions.
- **Install/Uninstall**: Add or remove Homebrew packages with automatic GitHub synchronization.
- **Scratchpad**: Instant access to your daily worklog (`micro`). Configurable paths for Mac, WSL, and Linux via the **Settings** menu.
- **Execute Shortcut**: Trigger complex Tmux window/pane operations via a menu.
- **Maintenance**: Access `dot-sync`, `dot-pull`, and interactive environment reloading with component selection.
- **Keyboard Diagnostics**: A built-in utility to diagnose and resolve keyboard shortcut issues.

### Theme System
PolyTerm includes a dynamic theme system controlled by the `POLYTERM_THEME` setting.

**Selecting a theme** (via palette):
1. Open the Command Palette (`Ctrl+Shift+P`).
2. Go to **Settings** → **Theme...**.
3. Choose from available presets (Peppermint, Catppuccin Mocha, Tokyo Night) or any custom theme you've created.
4. The fzf colors update immediately.

**Creating a custom theme** (via palette):
1. Go to **Settings** → **Theme...** → **Customize theme...**.
2. Pick a base preset to start from.
3. Select any color token to edit its hex value (`#rrggbb` format).
4. When finished, select **Save theme**, enter a name, and it's stored in `polyterm-data/settings/themes/`.

**Built-in presets** are located in `common/config/themes/`:
- `peppermint.json` — Dark, Peppermint Teal accent (default)
- `catppuccin-mocha.json` — Warm mauve/pink accents
- `tokyo-night.json` — Deep blue/purple accents

**Custom themes** are stored in `polyterm-data/settings/themes/` (user-private).

### Zellij Theme Colors
Zellij has its own theme system using `.kdl` files in `common/config/zellij/themes/`.

**Editing Zellij theme colors** (via palette):
1. Open **Configuration Manager...** → **Zellij...** → **Theme Colors...**.
2. Pick a theme to edit. The active Zellij theme is marked with `●`.
3. Select any of the 11 color tokens to change its hex value.
4. Type `default` or `reset` to restore the original value.
5. Select **Save**, then restart Zellij for changes to take effect.

---

## 🗖 Tmux Shortcuts & Navigation

PolyTerm uses `Ctrl+Shift` keybindings for a consistent experience across all platforms.

### Window & Session Management
- **`Ctrl+Shift+m`**: New Window
- **`Ctrl+Shift+e`**: Kill Window
- **`Ctrl+Shift+Up` / `Ctrl+Shift+Down`**: Cycle Windows
- **`Ctrl+Shift+,`**: New Session
- **`Ctrl+Shift+0`**: Cycle Sessions
- **`Ctrl+Shift+w`**: Kill Session

### Pane Management (2x2 Focus Grid)
- **`Ctrl+Shift+1`**: Create/Split Pane (Maximum 4 per window)
- **`Ctrl+Shift+2`**: Close/Kill Pane
- **`Ctrl+Shift+Left` / `Ctrl+Shift+Right`**: Cycle Panes
- **Ergonomics**: 
    - **Visual Padding**: An empty border header creates "air" at the top of each pane for a cleaner look.
    - **Active Highlighting**: The active pane is displayed with a bright blue border and full background brightness, while inactive panes are slightly dimmed for better focus.

### Selection & Clipboard
- **`Shift+Arrows`**: While not in an editor, holding Shift and pressing an arrow key will automatically enter Tmux **copy-mode** and begin text selection.
- **`Ctrl+c`**: While in copy-mode, copies the current selection to the system clipboard and exits copy-mode.
- **`Mouse Support`**: Mouse dragging also triggers selection and copies to the clipboard on release.

### System & Navigation
- **`Ctrl+Shift+P`**: Open Command Palette
- **`Ctrl+Shift+r`**: Reload Configuration (`dot-reload`). This reloads both Zsh and Tmux configs even if executed from a non-Tmux shell.

---

## 🐚 Shell Features (Zsh)

- **Automated Cockpit**: Terminal launch automatically switches to Zsh and initializes a Tmux "default" session.
- **Smart Dashboard**: A dedicated `Dashboard` session starts with `btop` and `docker ps` on launch.
- **Unified Prompt**: Shell prompt displays `username@hostname $ ` (green username, blue hostname) across all platforms. Uses Zsh `%n` and `%m` expansion sequences for live system values.
- **Welcome Banner**: A themed ASCII art banner displays at shell startup and after the `clear` command. Toggle via `POLYTERM_WELCOME` in Settings or set `POLYTERM_WELCOME="off"` in your `.polyterm_settings`.
- **AI & LLM Aliases**: Use `gemini`, `gemini-flash`, and `gemini-pro` for context-aware AI interactions. All sessions include a **1-hour timeout** to manage costs.
- **`search <query>`**: Instant DuckDuckGo search from the command line via `ddgr`.
- **`dot-sync`**: Automated workflow that pulls remote changes (with rebase), checks for missing dependencies (self-healing), runs `brew bundle dump`, git adds, commits with a timestamp, and pushes. Falls back to merge if rebase fails.
- **`dot-pull`**: Automated workflow that pulls latest changes (with rebase) and runs `brew bundle` to stay in sync. Automatically sets `pull.rebase true` to prevent divergent branches across multi-device workflows.

---

## 📁 Data Storage

PolyTerm separates **read-only configuration** from **mutable user state** across two repositories:

| Repository | Contains | Mutable? |
|------------|----------|----------|
| `dotfiles/` | Scripts, shell configs, themes, Brewfiles, docs | No — read-only code |
| `dotfiles-data/` | Settings, device registry, caches, per-device data | Yes — user state |

### What goes where

**`dotfiles/`** (shared across all devices):
- `common/config/tmux/`, `common/config/zellij/` — multiplexer configs
- `common/palette/` — command palette scripts
- `OS/{mac,wsl,linux}/zshrc` — shell configs
- `common/config/themes/` — built-in theme JSONs

**`dotfiles-data/`** (per-device isolation):
- `settings/.polyterm_settings` — runtime preferences
- `settings/themes/` — user-custom themes
- `device-list.yml` — multi-device registry
- `cache/OS/{mac,wsl,linux}/` — cached app descriptions
- `hledger/<device-id>/` — per-device hledger journals
- `editor/buffers/<device-id>/` — per-device Micro editor state
- `scratchpad/<device-id>/` — per-device scratchpad content

### Customizing the data path

By default, `dotfiles-data/` lives as a sibling to `dotfiles/` (e.g., `~/polyterm-data`). To change this, set `DOTFILES_DATA` in `~/.zshenv` before the shell loads:

```bash
export DOTFILES_DATA="/your/custom/path/to/polyterm-data"
```

This works on all platforms since `~/.zshenv` is sourced before `~/.zshrc`.

---

## 🛡️ Security & Vulnerability Management

PolyTerm prioritizes the security of your development environment with integrated scanning and automated remediation.

### The `dot-scan` Command
Run `dot-scan` at any time to perform a comprehensive security audit of your repository and system.

### Gemini CLI Auto-Updates
The Gemini CLI is configured to automatically check for and apply updates in the background whenever a new terminal session is started. This ensures your environment always benefits from the latest features, security patches, and improvements without manual intervention.

**What it checks:**
1.  **Package Vulnerabilities**: Scans for outdated Homebrew packages and **automatically upgrades** them to the latest secure versions.
2.  **System Health**: Runs `brew doctor` to detect configuration issues and potential conflicts.
3.  **Static Analysis**: Uses `shellcheck` to scan all shell scripts for logic errors and security vulnerabilities.
4.  **Secret Detection**: Proactively scans for hardcoded API keys, tokens, and credentials.
5.  **System Audit**: Executes a `lynis` security audit for deep system-level inspection.

### Continuous Monitoring
Security scans are automatically performed during:
-   **Installation**: Ensures your fresh setup is secure from the start.
-   **`dot-pull`**: Scans for vulnerabilities immediately after updating your configurations.
-   **`dot-sync`**: Performs a pre-sync dependency check (self-healing) and security scan to ensure no sensitive data is pushed to GitHub.

---

## 📝 Micro Editor & PolyMark

PolyTerm includes a customized **Micro** editor configuration located in `common/micro`.
- **Syntax**: Features the custom **PolyMark** syntax highlighting.
- **Theme**: Uses the `PolyMark.micro` colorscheme for a high-contrast, aesthetic editing experience.
- **Selection**: Supports **GUI-style selection** using `Shift+Arrows`.
- **Copying**: Use **`Ctrl+c`** to copy selected text to the system clipboard.
- **Deployment**: Configurations are automatically symlinked to `~/.config/micro`.

---

## 🛠️ Troubleshooting

### Shortcuts Not Working
If `Ctrl+Shift+P` or other shortcuts don't respond:
1.  **Ensure Ctrl+Shift support**: Use iTerm2, WezTerm, Alacritty, or Windows Terminal. macOS Terminal.app does not distinguish Ctrl+Shift from Ctrl.
2.  **WSL/Linux**: Run "Keyboard Diagnostics" in the Command Palette or execute `polyterm palette` → `Keyboard Diagnostics`.
3.  **Check for conflicts**: Some terminal emulators or multiplexers may intercept Ctrl+Shift combinations. Check your terminal's keybinding settings.

### Monochrome Display
If the terminal lacks color:
- Ensure your terminal emulator supports **TrueColor (24-bit)**.
- PolyTerm automatically exports `COLORTERM=truecolor` and `MICRO_TRUECOLOR=1` in your `.zshrc`.
