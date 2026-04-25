# Dotfiles Features

## 🖥️ Cross-Platform Compatibility
- **Hybrid Support**: Dedicated configurations for both **macOS** (`mac/`) and **WSL/Ubuntu** (`wsl/`).
- **Dynamic OS Detection**: Scripts like `palette.sh` automatically detect the environment to apply correct paths and package managers.

## 🎛️ Unified Command Palette (`palette.sh`)
- **VSCode-Style Popup**: Triggered via `Alt+p` in Tmux for a centralized control hub.
- **App Launcher**: `fzf`-powered interface to quickly launch tools defined in your `Brewfile` with **dynamic blurbs** (fetched from Homebrew).
- **Executable Shortcuts**: Instant access to trigger all custom Tmux keybindings directly from the palette.
- **Safety Measures**: Integrated confirmation prompts for destructive actions (uninstallation, session killing) to prevent accidental execution.
- **Modern UI**: Replaced standard emojis with consistent **Nerd Font glyphs** for a professional, high-fidelity terminal experience.
- **Package Management**: Interactive UI to install or uninstall Homebrew packages with **automatic synchronization** to GitHub.
- **Workflow Sync**: Integrated commands to pull latest changes or sync local updates to GitHub.

## 🗖 Advanced Tmux Configuration
- [x] **Session Management**: Rapid creation (`Alt+,`), cycling (`Alt+0`), and termination (`Alt+w`) of tmux sessions.
- [x] **2x2 Grid Management**: Custom bindings (`Alt+1`, `Alt+2`) for rapid tiling and pane management (limited to 4 panes for focus).
- [x] **Smart Dashboard**: Auto-starts a session named "Dashboard" with `btop` and `docker ps` on launch.
- [x] **Dynamic Clipboard**: Context-aware clipboard integration using `pbcopy` (macOS) and `xclip` (Linux).
- [x] **Aesthetics**: Integrated with **Catppuccin** theme and a custom-formatted status bar.
- [x] **Peppermint Design System**: Centralized design language in `DESIGN.md` using the **Peppermint** palette for high-contrast, comfortable ergonomics.
- [x] **Pane Differentiation**: Active panes use a solid black background (`#000000`) and blue borders, while inactive panes are subtly dimmed (`#1c1c1c`) for focused workflows.
- [x] **Plugin Power**: Managed via `tpm` with support for `resurrect` and `continuum` for session persistence.

## 📦 Declarative Package Management
- **Brewfiles**: OS-specific lists for CLI tools (e.g., `btop`, `fzf`, `ranger`, `superfile`) and VSCode extensions.
- **Automated Maintenance**: `dot-sync` automatically runs `brew bundle dump` before pushing; `dot-pull` runs `brew bundle` after pulling.
- **Verbose Output**: All installation, uninstallation, and synchronization processes provide detailed real-time feedback via the `--verbose` flag.
- **Consistency**: Ensures the same environment can be reproduced across different machines.

## 🐚 Shell Automation (Zsh)
- **Automated Startup**: Configured to auto-switch from Bash to Zsh and immediately initialize the Tmux cockpit upon terminal entry.
- **Dotfile Syncing**: `dot-sync` and `dot-pull` functions to automate Git operations and configuration reloading.
- **Integrated Reloading**: `dot-reload` function to instantly refresh both Zsh and Tmux environments across platforms.
- **Interactive Search**: `search` alias powered by `ddgr` for DuckDuckGo results directly in the terminal.
- **Automated SSH**: Automatic SSH agent initialization and key loading (WSL).
- **Aesthetics**: Support for `zsh-syntax-highlighting` and customized `ls` colors across platforms.

## 🚀 One-Command Installation
- **Unified Installer**: A single `install.sh` script that works across macOS, WSL, and generic Linux.
- **Remote Execution**: Supports bootstrap installation via `curl | bash` for rapid environment setup.
- **Safety First**: Automatically backs up existing configuration files before applying dotfiles.
- **Full Automation**: Handles Homebrew installation, repository cloning, symlinking, package installation (`brew bundle`), and TPM setup in one go.

## 🛠️ PolyTerm CLI
- **Centralized Command**: A unified `polyterm` command to manage your entire environment.
- **Homebrew Tap Support**: Installable via `brew install polyterm` from your personal tap.
- **Management Subcommands**: Built-in support for `setup`, `sync`, `pull`, and `reload`.
- **Instant Palette**: Launch the Command Palette directly from the CLI.

## 📝 Micro Editor Customization
- **PolyMark Syntax**: Custom syntax highlighting rules defined in `PolyMark.yaml`.
- **Theming**: A dedicated `PolyMark.micro` colorscheme for a consistent editing experience.

## 🔄 PolyMark Translation (Sublime to Micro)
- **Automated Mapping**: Logic to translate `.sublime-syntax` YAML rules to Micro's `.yaml` syntax.
- **Color Conversion**: Map `.sublime-color-scheme` JSON colors to Micro's `.micro` colorscheme format.
- **Ecosystem Alignment**: Ensure the PolyOS aesthetic is preserved across different editors.

## 🛡️ Security & Vulnerability Management
- **Security Vulnerability Scanning**: Integrated `dot-scan` function that performs static analysis on scripts (`shellcheck`), checks for outdated packages (`brew outdated`), audits Homebrew health (`brew doctor`), scans for hardcoded secrets, and runs a system security audit (`lynis`).
- **Automated Security Fixes**: Automatically upgrades outdated packages and provides actionable advice for detected vulnerabilities during installation and updates.
- **Continuous Monitoring**: Security scans are automatically triggered during `dot-pull` (after updates) and `dot-sync` (before pushing) to ensure repository integrity.
- **Secret Detection**: Proactive heuristic scanning for API keys, tokens, and hardcoded credentials within the repository to prevent accidental exposure.

## 🛠️ System Diagnostics & Troubleshooting
- **Issue Tracking**: Centralized `issues.md` for documenting and resolving configuration bugs.
- **Terminal Compatibility**: Ensuring TrueColor/RGB support across Tmux and shell environments.
