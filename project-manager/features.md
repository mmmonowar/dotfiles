# Dotfiles Features

## [FEAT-01] ✅ Cross-Platform Compatibility
- **Status**: Completed
- **Description**: Dedicated compatibility layer allowing smooth configuration and script execution across distinct operating systems.
- **Details**:
  - **Hybrid Support**: Dedicated configurations for both **macOS** (`mac/`) and **WSL/Ubuntu** (`wsl/`).
  - **Dynamic OS Detection**: Scripts like `palette.sh` automatically detect the environment to apply correct paths and package managers.

## [FEAT-02] ✅ Unified Command Palette (`palette.sh`)
- **Status**: Completed
- **Description**: A central interactive keyboard-driven popup menu to discover, run, and manage system tools and documentation.
- **Details**:
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

## [FEAT-03] ✅ Advanced Tmux Configuration
- **Status**: Completed
- **Description**: High-fidelity terminal multiplexer setup optimizing session workflow, grid layouts, and visual ergonomics.
- **Details**:
  - **Session Management**: Rapid creation (`Alt+,`), cycling (`Alt+0`), and termination (`Alt+w`) of tmux sessions.
  - **2x2 Grid Management**: Custom bindings (`Alt+1`, `Alt+2`) for rapid tiling and pane management (limited to 4 panes for focus).
  - **Smart Dashboard**: Auto-starts a session named "Dashboard" with `btop` and `docker ps` on launch.
  - **Dynamic Clipboard**: Context-aware clipboard integration using `pbcopy` (macOS) and `xclip` (Linux).
  - **GUI-style Selection**: Support for `Shift+Arrow` keys to enter copy-mode and select text in the scrollback, with `Ctrl+c` to copy to the system clipboard.
  - **Aesthetics**: Integrated with a custom-formatted minimalist status bar featuring a Pure Black background, subtle white inactive elements, and a high-contrast Peppermint Teal focal window with modern icons (`⸎`).
  - **Sublime-Inspired Aesthetics**: Enhanced Tmux configuration with Pure Black backgrounds, vibrant Peppermint Teal active accents (`#14b8a6`), and subtle Bright Black pane borders (`#2a2a2a`) for an immersive editor-like feel.
  - **Clean Interface**: Border text labels are disabled (`pane-border-status off`) to maximize screen real estate and minimize visual noise.
  - **Peppermint Design System**: Centralized design language in `DESIGN.md` for consistent high-contrast ergonomics.
  - **Plugin Power**: Managed via `tpm` with support for `resurrect` and `continuum` for session persistence.

## [FEAT-03b] ✅ Multiplexer Switching (Tmux ↔ Zellij)
- **Status**: Completed
- **Description**: Dynamic switching between Tmux and Zellij terminal multiplexers with environment variable control and unified command support.
- **Details**:
  - **Dual-Config Support**: Dedicated configurations for both `tmux` (`common/config/tmux/tmux.conf`) and `zellij` (`common/config/zellij/config.kdl`) with shared Peppermint design language.
  - **Environment Variable Control**: `POLYTERM_MULTIPLEXER` environment variable (`tmux` or `zellij`) selects the active multiplexer across all OS profiles (Linux, macOS, WSL).
  - **OS-Specific Defaults**: Default multiplexer is `tmux` on Linux/macOS and `zellij` on WSL for optimal native experience.
  - **Palette Compatibility**: All palette shortcuts (`execute_shortcut()`) and helper functions (`trigger_zsh_func()`) transparently detect the active multiplexer via `$TMUX`/`$ZELLIJ` environment variables and execute the equivalent command.
  - **Shared Keybindings**: Common `Alt/Meta` keybinding patterns (pane navigation, tab management, session cycling) mirrored across both multiplexers for muscle-memory consistency.
  - **Unified Installation**: `install.sh` symlinks both tmux and zellij configurations; TPM is installed for tmux plugin support.

## [FEAT-04] ✅ Declarative Package Management
- **Status**: Completed
- **Description**: Automated installation, updating, and synchronization of environment packages and CLI utilities.
- **Details**:
  - **Brewfiles**: OS-specific lists for CLI tools (e.g., `btop`, `fzf`, `ranger`, `superfile`) and VSCode extensions.
  - **Automated Maintenance**: `dot-sync` automatically checks and installs/updates missing dependencies (self-healing) before pushing; `dot-pull` runs `brew bundle` after pulling.
  - **Self-Updating Environment**: Gemini CLI automatically updates in the background upon every shell startup to ensure the latest features and security patches are applied.
  - **Verbose Output**: All installation, uninstallation, and synchronization processes provide detailed real-time feedback via the `--verbose` flag.
  - **Consistency**: Ensures the same environment can be reproduced across different machines.

## [FEAT-05] ✅ Shell Automation (Zsh)
- **Status**: Completed
- **Description**: Streamlined interactive shell experience with self-healing, smart aliases, and fast reload functions.
- **Details**:
  - **Automated Startup**: Configured to auto-switch from Bash to Zsh and immediately initialize the Tmux cockpit upon terminal entry.
  - **Dotfile Syncing**: `dot-sync` and `dot-pull` functions to automate Git operations and configuration reloading with built-in self-healing logic.
  - **Accounting Integration**: Automated symbolic linking of the `hledger` journal file (`~/.hledger.journal`) to the `Accounting-Management-System` repository. This ensures that all accounting data "stays" in the dedicated repository and is visible as `hledger.journal` for easy tracking, while remaining fully accessible to the `hledger` CLI on any device.
  - **Integrated Reloading**: `dot-reload` function to instantly refresh both Zsh and Tmux environments across platforms; `dot-reload-interactive` for interactive reload with fzf multi-select menu; `dot-reload-all` for non-interactive comprehensive reload.
  - **Local Overrides**: Support for machine-specific, non-synced configurations via `~/.zshrc_local` for local environment tailoring.
  - **AI & LLM Aliases**: Context-aware aliases for Gemini CLI (`gemini`, `gemini-flash`, `gemini-pro`) with a 1-hour session timeout, billing monitoring (`check-spend`), and a large-file safety wrapper (`ask_gemini`) that are conditionally enabled based on the git user email, optimizing for cost and performance.
  - **Interactive Search**: `search` alias powered by `ddgr` for DuckDuckGo results directly in the terminal.
  - **Automated SSH**: Automatic SSH agent initialization and key loading (WSL).
  - **Aesthetics**: Support for `zsh-syntax-highlighting` and customized `ls` colors across platforms.

## [FEAT-06] ✅ Gemini CLI Integration
- **Status**: Completed
- **Description**: Integrated terminal interface for interacting with Gemini Large Language Models safely and cost-effectively.
- **Details**:
  - **Model-Specific Aliases**: Context-aware aliases (`gemini`, `gemini-flash`, `gemini-pro`) and billing monitoring (`check-spend`) conditionally enabled based on git user email.
  - **Configuration Sync**: Non-sensitive settings (model choice, safety thresholds, temperature) are synchronized across platforms via `common/config/gemini/settings.json`.
  - **Process Management**: 'Kill Gemini' command palette item to instantly terminate all Gemini-related processes across all tmux sessions while preserving the active agent.

## [FEAT-07] ✅ One-Command Installation
- **Status**: Completed
- **Description**: Universal bootstrap installer supporting remote one-command setup across different OS profiles.
- **Details**:
  - **Unified Installer**: A single `install.sh` script that works across macOS, WSL, and generic Linux.
  - **Remote Execution**: Supports bootstrap installation via `curl | bash` for rapid environment setup.
  - **Safety First**: Automatically backs up existing configuration files before applying dotfiles.
  - **Full Automation**: Handles Homebrew installation, repository cloning, symlinking, package installation (`brew bundle`), and TPM setup in one go.

## [FEAT-08] ✅ PolyTerm CLI
- **Status**: Completed
- **Description**: Central CLI wrapper allowing users to manage setup, sync, reload, and palette operations directly from a terminal subcommand.
- **Details**:
  - **Centralized Command**: A unified `polyterm` command to manage your entire environment.
  - **Homebrew Tap Support**: Installable via `brew install polyterm` from your personal tap.
  - **Management Subcommands**: Built-in support for `setup`, `sync`, `pull`, and `reload`.
  - **Instant Palette**: Launch the Command Palette directly from the CLI.

## [FEAT-09] ✅ Micro Editor Customization
- **Status**: Completed
- **Description**: Tailored Micro editor configurations providing custom syntax styling and native OS-like key handling.
- **Details**:
  - **PolyMark Syntax**: Custom syntax highlighting rules defined in `PolyMark.yaml`.
  - **Theming**: A dedicated `PolyMark.micro` colorscheme for a consistent editing experience.
  - **GUI-style Selection**: Support for `Shift+Arrow` keys for text selection and `Ctrl+c` for copying to the system clipboard, ensuring a familiar editor experience.

## [FEAT-10] ✅ PolyMark Translation (Sublime to Micro)
- **Status**: Completed
- **Description**: Automated translation engine converting Sublime Text `.sublime-syntax` and color schemes to Micro editor formats.
- **Details**:
  - **Automated Mapping**: Logic to translate `.sublime-syntax` YAML rules to Micro's `.yaml` syntax.
  - **Color Conversion**: Map `.sublime-color-scheme` JSON colors to Micro's `.micro` colorscheme format.
  - **Ecosystem Alignment**: Ensure the PolyOS aesthetic is preserved across different editors.

## [FEAT-11] ✅ Security & Vulnerability Management
- **Status**: Completed
- **Description**: Code and system audits evaluating configuration script safety, outdated packages, and secrets leakage.
- **Details**:
  - **Security Vulnerability Scanning**: Integrated `dot-scan` function that performs static analysis on scripts (`shellcheck`), checks for outdated packages (`brew outdated`), audits Homebrew health (`brew doctor`), scans for hardcoded secrets, and runs a system security audit (`lynis`).
  - **Automated Security Fixes**: Automatically upgrades outdated packages and provides actionable advice for detected vulnerabilities during installation and updates.
  - **Continuous Monitoring**: Security scans are automatically triggered during `dot-pull` (after updates) and `dot-sync` (before pushing) to ensure repository integrity.
  - **Secret Detection**: Proactive heuristic scanning for API keys, tokens, and hardcoded credentials within the repository to prevent accidental exposure.

## [FEAT-12] ✅ System Diagnostics & Troubleshooting
- **Status**: Completed
- **Description**: Documented fixes, terminal compatibility standards, and diagnostic procedures for common configuration bugs.
- **Details**:
  - **Issue Tracking**: Centralized `issues.md` for documenting and resolving configuration bugs.
  - **Terminal Compatibility**: Ensuring TrueColor/RGB support across Tmux and shell environments.

## [FEAT-13] ✅ Device Tracking & Registry
- **Status**: Completed
- **Description**: System for identifying and logging specifications of active hardware environments on synchronization.
- **Details**:
  - **Dynamic Device List**: Stores registered devices and environment properties in a centralized YAML file (`data/device-list.yml`).
  - **Detailed Machine Profiles**: Captures hostname, username, device model, operating system, OS version, local IP address, and last synchronization time.
  - **Reference Identifier**: Generates a clean, hostname-based identifier (`device_id`) to simplify machine-specific referencing in scripts.
  - **Sync Integration**: Automates the collection and updates of device profiles during git-based synchronization (`dot-sync`).

## [FEAT-14] ✅ OS-Specific Configuration Refactoring
- **Status**: Completed
- **Description**: Structured folder reorganization standardizing cross-platform configs under a unified hierarchal layout.
- **Details**:
  - **Centralized OS Directory**: Migrated all OS-specific directories (`mac/`, `linux/`, `wsl/`) under a unified `OS/` folder at the repository root.
  - **Hierarchical Config Locality**:
    - **OS-Specific Configs**: Placed at the root of their respective OS directory: `OS/<mac/linux/wsl>/<config>`.
    - **Device-Specific Configs**: Placed in subdirectories matching the device identifier: `OS/<mac/linux/wsl>/<device-identifier>/<config>`.
  - **System Mirroring**: Configured installer, dynamic updates, and symlink references to dynamically resolve paths using this hierarchical layout.

## [FEAT-15] ✅ Common Directory Refactoring & Decoupling
- **Status**: Completed
- **Description**: Reorganized layout separating shared static configurations from programmatic automation scripts.
- **Details**:
  - **Modularized Shared Configurations**: Reorganized all cross-platform configs under `common/config/` nested by program folders (e.g., `common/config/tmux/tmux.conf`, `common/config/glow/glow.yml`).
  - **Unified Command Palette Library**: Grouped all cross-platform shell commands, automation tools, and helper scripts (e.g., `security.sh`, `hledger-sync.sh`, `fix-alt-keys.sh`) under `common/palette/`.

## [FEAT-17] 🛠️ Interactive Device Manager (Command Palette)
- **Status**: Completed
- **Description**: Dedicated sub-menu in the command palette for device registry management, providing scan, SSH, and manual entry capabilities without leaving the terminal UI.
- **Details**:
  - **Centralized Sub-Menu**: A "Device Manager..." entry in the main menu (item 14) opens a dedicated `devices_menu()` with three management actions.
  - **Auto-Scan**: "Scan Current Device" triggers `update_device.py` to detect the current machine's hostname, OS, IP, model, and version, and updates `data/device-list.yml` in real time.
  - **SSH Launcher**: "SSH into Device" reads `data/device-list.yml` via `device_manager.py --list`, presents an `fzf` picker with device details, and executes `ssh user@ip` on selection — skipping devices with only loopback addresses.
  - **Manual Entry**: "Manual Device Entry" prompts the user through all registry fields (ID, username, device-name, model, OS, version, IP) with auto-detected defaults, shows a summary, and writes to `data/device-list.yml` via `device_manager.py --update`.
  - **Global Search Access**: All three device actions appear in the flattened global search results, allowing direct invocation from the main palette search without navigating the sub-menu.
  - **Scripts**: New `common/palette/devices.sh` (bash module) and `common/palette/device_manager.py` (Python YAML utility); sourced from `palette.sh` and dispatched from `menu.sh`.

## [FEAT-16] 🛠️ Automated Symlink Health Checks
- **Status**: Planned
- **Description**: Automated verification engine to audit, validate, and repair configuration symlinks across operating systems.
- **Details**:
  - **Health Auditing**: Programmatic checks for broken, misaligned, or missing symlinks mapping repository configurations to user home folders.
  - **Self-Healing Resolution**: Auto-reconstruction of broken links to ensure clean state deployment.

## [FEAT-19] 🛠️ Interactive Zellij Configuration Manager (Command Palette)
- **Status**: In Progress
- **Description**: Dedicated sub-menu in the command palette for reading, editing, and saving Zellij terminal multiplexer configuration options without leaving the terminal UI.
- **Details**:
  - **Configuration Manager Menu**: New main menu item (16) "Configuration Manager..." that opens a sub-menu with "Zellij..." as the first config type, designed for future extensibility to Tmux, Micro, Gemini, and other configs.
  - **Live Config Mirroring**: The settings list dynamically reads `common/config/zellij/config.kdl` to display all active (non-commented) top-level settings with their current values — the menu always reflects the actual file contents.
  - **Three Editing Modes**:
    - **Boolean Toggle**: Settings like `simplified_ui`, `mouse_mode`, `pane_frames` are edited via an fzf `true`/`false` picker.
    - **Choice Selector**: Settings with enumerated values (`theme`, `default_mode`, `copy_clipboard`) present an fzf picker with valid options (themes discovered from `themes/` directory, modes, clipboard targets).
    - **Free-Text Input**: Settings like `default_shell`, `copy_command`, `default_layout` use a `read -r` prompt with the current value pre-filled for quick editing.
  - **Rich Metadata**: Each setting displays a descriptive name, current value, and one-line description in the fzf list, with an extended hint shown in the preview pane.
  - **Save & Cancel**: Changes are written back to `config.kdl` via a line-preserving Python backend that maintains all comments and formatting. Pressing Esc at any point cancels without changes.
  - **Python Backend**: `kdl_config.py` handles KDL parsing, type detection, metadata lookup, and idempotent write-back — keeping the shell layer focused on UI.
  - **Cross-Platform**: Works identically in Tmux and Zellij sessions; the palette's floating pane and `trigger_zsh_func` integration are fully supported.
  - **Scripts**: New `common/palette/config_manager.sh` (bash module) and `common/palette/kdl_config.py` (Python KDL utility); sourced from `palette.sh` and dispatched from `menu.sh`.

## [FEAT-18] 🛠️ Interactive Configuration Reload
- **Status**: Completed
- **Description**: Interactive reload system that lets users choose which components to refresh via fzf multi-select menu, with fallback non-interactive mode.
- **Details**:
  - **Interactive Menu**: fzf-based multi-select interface for choosing which components to reload (TAB to select, CTRL-A for all, CTRL-D for none).
  - **Selectable Components**: Shell configs, PolyTerm settings, multiplexer config, and multiplexer restart.
  - **Progress Tracking**: Step counter showing progress (e.g., [2/3]) during reload.
  - **CLI Flags**: `polyterm reload` (interactive), `polyterm reload --all` (non-interactive), `--shell`, `--settings`, `--mux-config`, `--mux-restart`.
  - **Phase 1 — Shell Configs**: Sources `~/.zshrc`, `~/.bashrc`, and re-loads `sync.sh` automation functions.
  - **Phase 2 — PolyTerm Environment**: Reloads `.polyterm_settings` for immediate environment variable updates.
  - **Phase 3 — Multiplexer Config**: Hot-reloads tmux config (`tmux source-file`) or notes zellij config will apply on next session.
  - **Phase 4 — Session Restart (Tmux)**: Saves state via tmux-resurrect, creates fresh session with a temporary name, switches client, kills the old session, and renames back — preserving the server and original session name.
  - **Phase 4 — Session Restart (Zellij)**: Terminates the session with guidance to re-run `zellij` manually.
  - **Integrated Dispatch**: Available from the Command Palette (item 11 — Reload Configs...) and CLI (`polyterm reload`).
