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

### WSL Installation Notes

```bash
brew update && brew cleanup --prune=all && brew install polyterm
```

The formula uses a manual `git clone` in its install method to avoid a known Homebrew 6.0.12 `GitDownloadStrategy` bug on WSL.

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

---

## 🎛️ Unified Command Palette (`Alt+p`)

The heart of PolyTerm is the **Command Palette**, a VSCode-style interactive menu triggered via `Alt+p` (or `Meta+p`) inside Tmux.

### Features:
- **Launch App**: Search and launch CLI tools defined in your Brewfile with dynamic descriptions.
- **Install/Uninstall**: Add or remove Homebrew packages with automatic GitHub synchronization.
- **Scratchpad**: Instant access to your daily worklog (`micro`). Configurable paths for Mac, WSL, and Linux via the **Settings** menu.
- **Execute Shortcut**: Trigger complex Tmux window/pane operations via a menu.
- **Maintenance**: Access `dot-sync`, `dot-pull`, and interactive environment reloading with component selection.
- **Alt-Key Fix**: A built-in utility to diagnose and fix keyboard shortcut issues.

### Theme System
PolyTerm includes a dynamic theme system controlled by the `POLYTERM_THEME` setting.

**Selecting a theme** (via palette):
1. Open the Command Palette (`Alt+p`).
2. Go to **Settings** → **Theme...**.
3. Choose from available presets (Peppermint, Catppuccin Mocha, Tokyo Night) or any custom theme you've created.
4. The fzf colors update immediately.

**Creating a custom theme** (via palette):
1. Go to **Settings** → **Theme...** → **Customize theme...**.
2. Pick a base preset to start from.
3. Select any color token to edit its hex value (`#rrggbb` format).
4. When finished, select **Save theme**, enter a name, and it's stored in `dotfiles-data/settings/themes/`.

**Built-in presets** are located in `common/config/themes/`:
- `peppermint.json` — Dark, Peppermint Teal accent (default)
- `catppuccin-mocha.json` — Warm mauve/pink accents
- `tokyo-night.json` — Deep blue/purple accents

**Custom themes** are stored in `dotfiles-data/settings/themes/` (user-private).

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
- **Ergonomics**: 
    - **Visual Padding**: An empty border header creates "air" at the top of each pane for a cleaner look.
    - **Active Highlighting**: The active pane is displayed with a bright blue border and full background brightness, while inactive panes are slightly dimmed for better focus.

### Selection & Clipboard
- **`Shift+Arrows`**: While not in an editor, holding Shift and pressing an arrow key will automatically enter Tmux **copy-mode** and begin text selection.
- **`Ctrl+c`**: While in copy-mode, copies the current selection to the system clipboard and exits copy-mode.
- **`Mouse Support`**: Mouse dragging also triggers selection and copies to the clipboard on release.

### System & Navigation
- **`Alt+p`**: Open Command Palette
- **`Alt+r`**: Reload Configuration (`dot-reload`). This reloads both Zsh and Tmux configs even if executed from a non-Tmux shell.

---

## 🐚 Shell Features (Zsh)

- **Automated Cockpit**: Terminal launch automatically switches to Zsh and initializes a Tmux "default" session.
- **Smart Dashboard**: A dedicated `Dashboard` session starts with `btop` and `docker ps` on launch.
- **AI & LLM Aliases**: Use `gemini`, `gemini-flash`, and `gemini-pro` for context-aware AI interactions. All sessions include a **1-hour timeout** and billing monitoring (`check-spend`) to manage costs.
- **`search <query>`**: Instant DuckDuckGo search from the command line via `ddgr`.
- **`dot-sync`**: Automated workflow that checks for missing dependencies (self-healing), runs `brew bundle dump`, git adds, commits with a timestamp, and pushes.
- **`dot-pull`**: Automated workflow that pulls latest changes and runs `brew bundle` to stay in sync.

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

### Alt/Option Keys Not Working
If `Alt+p` or other shortcuts fail:
1.  **WSL/Linux**: Run the "Fix Alt Keys" option in the Command Palette or execute `polyterm palette` -> `Fix Alt Keys`.
2.  **macOS (iTerm2)**: Go to `Settings` -> `Profiles` -> `Keys` and set `Left Option key` to `Esc+`.
3.  **macOS (Terminal.app)**: Go to `Settings` -> `Profiles` -> `Keyboard` and check `Use Option as Meta key`.

### Monochrome Display
If the terminal lacks color:
- Ensure your terminal emulator supports **TrueColor (24-bit)**.
- PolyTerm automatically exports `COLORTERM=truecolor` and `MICRO_TRUECOLOR=1` in your `.zshrc`.
