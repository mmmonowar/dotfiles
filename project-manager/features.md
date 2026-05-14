# Dotfiles Features

## 🖥️ Cross-Platform Compatibility
- **Hybrid Support**: Dedicated configurations for both **macOS** (`mac/`) and **WSL/Ubuntu** (`wsl/`).
- **Dynamic OS Detection**: Scripts like `palette.sh` automatically detect the environment to apply correct paths and package managers.

## 🎛️ Unified Command Palette (`palette.sh`)
- **VSCode-Style Popup**: Triggered via `Alt+p` in Tmux for a centralized control hub.
- **Unified Discovery**: A flattened search scope that allows you to find apps, documents, settings, and shortcuts directly from the main menu.
- **App Launcher**: `fzf`-powered interface to quickly launch tools defined in your `Brewfile` with **dynamic blurbs**.
- **Project Documents**: Dynamic document browser to read all files in `project-manager/` using `glow`.
- **User Experience Settings**: Dedicated "Settings" menu to toggle persistent preferences like security scans on push/pull.
- **Executable Shortcuts**: Instant access to trigger all custom Tmux keybindings directly from the palette.
- **Safety Measures**: Integrated confirmation prompts for destructive actions (uninstallation, session killing) to prevent accidental execution.
- **Modern UI**: Replaced standard emojis with consistent **Nerd Font glyphs** for a professional, high-fidelity terminal experience.
- **Package Management**: Interactive UI to install or uninstall Homebrew packages with **automatic synchronization** to GitHub.
- **PolyOS-dev Integration**: Dedicated sub-menu for PolyOS development tools, featuring `poly-sync` for automated cloning and updating of project repositories from GitHub.
- **Scratchpad Management**: Quick-access worklog with customizable paths per OS, directly configurable from the UI.
- **Workflow Sync**: Integrated commands to pull latest changes or sync local updates to GitHub.

## 🗖 Advanced Tmux Configuration
- [x] **Session Management**: Rapid creation (`Alt+,`), cycling (`Alt+0`), and termination (`Alt+w`) of tmux sessions.
- [x] **2x2 Grid Management**: Custom bindings (`Alt+1`, `Alt+2`) for rapid tiling and pane management (limited to 4 panes for focus).
- [x] **Smart Dashboard**: Auto-starts a session named "Dashboard" with `btop` and `docker ps` on launch.
- [x] **Dynamic Clipboard**: Context-aware clipboard integration using `pbcopy` (macOS) and `xclip` (Linux).
- [x] **GUI-style Selection**: Support for `Shift+Arrow` keys to enter copy-mode and select text in the scrollback, with `Ctrl+c` to copy to the system clipboard.
- [x] **Aesthetics**: Integrated with **Catppuccin** theme and a custom-formatted status bar.
- [x] **Sublime-Inspired Aesthetics**: Enhanced Tmux configuration with pure black backgrounds (`#000000`), vibrant teal active borders (`#14b8a6`), and subtle dark grey inactive borders (`#2a2a2a`) for an immersive editor-like feel.
- [x] **Clean Interface**: Border text labels are disabled (`pane-border-status off`) to maximize screen real estate and minimize visual noise.
- [x] **Peppermint Design System**: Centralized design language in `DESIGN.md` for consistent high-contrast ergonomics.
- [x] **Plugin Power**: Managed via `tpm` with support for `resurrect` and `continuum` for session persistence.

## 📦 Declarative Package Management
- **Brewfiles**: OS-specific lists for CLI tools (e.g., `btop`, `fzf`, `ranger`, `superfile`) and VSCode extensions.
- **Automated Maintenance**: `dot-sync` automatically checks and installs/updates missing dependencies (self-healing) before pushing; `dot-pull` runs `brew bundle` after pulling.
- **Self-Updating Environment**: Gemini CLI automatically updates in the background upon every shell startup to ensure the latest features and security patches are applied.
- **Verbose Output**: All installation, uninstallation, and synchronization processes provide detailed real-time feedback via the `--verbose` flag.
- **Consistency**: Ensures the same environment can be reproduced across different machines.

## 🐚 Shell Automation (Zsh)
- **Automated Startup**: Configured to auto-switch from Bash to Zsh and immediately initialize the Tmux cockpit upon terminal entry.
- **Dotfile Syncing**: `dot-sync` and `dot-pull` functions to automate Git operations and configuration reloading with built-in self-healing logic.
- **Accounting Integration**: Automated symbolic linking of the `hledger` journal file (`~/.hledger.journal`) to the `Accounting-Management-System` repository. This ensures that all accounting data "stays" in the dedicated repository and is visible as `hledger.journal` for easy tracking, while remaining fully accessible to the `hledger` CLI on any device.
- **Integrated Reloading**: `dot-reload` function to instantly refresh both Zsh and Tmux environments across platforms.
- **Local Overrides**: Support for machine-specific, non-synced configurations via `~/.zshrc_local` for local environment tailoring.
- **AI & LLM Aliases**: Context-aware aliases for Gemini CLI (`gemini`, `gemini-flash`, `gemini-pro`) with a 1-hour session timeout, billing monitoring (`check-spend`), and a large-file safety wrapper (`ask_gemini`) that are conditionally enabled based on the git user email, optimizing for cost and performance.
- **Interactive Search**: `search` alias powered by `ddgr` for DuckDuckGo results directly in the terminal.
- **Automated SSH**: Automatic SSH agent initialization and key loading (WSL).
- **Aesthetics**: Support for `zsh-syntax-highlighting` and customized `ls` colors across platforms.

## 🤖 Gemini CLI Integration
- [x] **Model-Specific Aliases**: Context-aware aliases (`gemini`, `gemini-flash`, `gemini-pro`) and billing monitoring (`check-spend`) conditionally enabled based on git user email.
- [x] **Configuration Sync**: Non-sensitive settings (model choice, safety thresholds, temperature) are synchronized across platforms via `common/gemini/settings.json`.
- [x] **Process Management**: 'Kill Gemini' command palette item to instantly terminate all Gemini-related processes across all tmux sessions while preserving the active agent.

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
- **GUI-style Selection**: Support for `Shift+Arrow` keys for text selection and `Ctrl+c` for copying to the system clipboard, ensuring a familiar editor experience.

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
