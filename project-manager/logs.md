## [2026-05-04-13-30-00] - Local-Only Zsh Overrides
- **Feature**: Implemented support for machine-specific Zsh configurations.
- **Details**:
    - Added logic to `linux/zshrc`, `mac/.zshrc`, and `wsl/zshrc` to source `~/.zshrc_local` if it exists.
    - This allows for local environment tailoring (e.g., custom environment variables, machine-specific aliases) without syncing them to Git.
    - Updated project documentation (`features.md`, `tasks.md`, `plan.md`) to reflect the new capability.

## [2026-05-04-13-00-00] - Gemini CLI Alias Timeout
- **Feature**: Added a 1-hour session timeout to all Gemini CLI aliases.
- **Details**:
    - Updated `linux/zshrc`, `mac/.zshrc`, and `wsl/zshrc` to wrap `gemini`, `gemini-flash`, and `gemini-pro` with the `timeout 1h` command.
    - This prevents accidental long-running sessions and optimizes resource usage.
    - Updated project documentation (`features.md`, `tasks.md`, `plan.md`) to reflect the change.

## [2026-05-04-14-35-00] - 'Kill Gemini' Palette Item
- **Feature**: Added a 'Kill Gemini' menu item to the command palette.
- **Details**:
    - Implemented `kill_gemini_processes` in `common/palette/helpers.sh` which uses `pgrep` and `kill -9`.
    - Integrated logic to exclude the current active agent's PID and its parent from termination.
    - Added menu item "Kill Gemini" to `common/palette/menu.sh`.
    - Updated project documentation to reflect the new capability.

## [2026-05-04-12-30-00] - Gemini CLI Safety Wrapper
- **Feature**: Implemented `ask_gemini` to filter large files.
- **Details**:
    - Added `ask_gemini` function to `linux/zshrc`, `wsl/zshrc`, and `mac/.zshrc`.
    - The function prevents Gemini from processing files larger than 50,000 bytes, providing a safety warning to manage cost and context window.
    - Handles platform-specific `stat` syntax for macOS and Linux.
    - Updated project documentation (`features.md`, `tasks.md`, `plan.md`) to reflect the new feature.

## [2026-05-04-12-15-00] - Gemini CLI Settings Synchronization
- **Feature**: Enabled cross-platform sync for non-sensitive Gemini CLI settings.
- **Details**:
    - Created `common/gemini/settings.json` to store shared model, chat, and safety configurations.
    - Updated `application-package/install.sh` to automatically symlink `~/.gemini/settings.json` to the repository version.
    - This ensures consistent behavior (e.g., temperature, safety thresholds) across WSL, Linux, and macOS environments.
    - Documented the new integration in `features.md`, `tasks.md`, and `plan.md`.

## [2026-05-04-12-00-00] - Conditional AI & LLM Aliases
- **Feature**: Implemented model-specific Gemini CLI aliases conditional on git user email.
- **Details**:
    - Added a new section `8. AI & LLM ALIASES` to `linux/zshrc`, `wsl/zshrc`, and `mac/.zshrc`.
    - Aliases `gemini` (flash-lite), `gemini-flash` (flash-3.0), and `gemini-pro` (pro-3.1) are only enabled if `git config user.email` matches `developer11.intxk@gmail.com`.
    - Integrated `check-spend` alias to monitor Google Cloud billing quotas and maintain the $4.50 budget cap.
    - This optimizes for cost-effective LLM usage while providing easy access to more powerful models when needed.
    - Updated project management documentation (`features.md`, `tasks.md`, `plan.md`) to reflect the new feature.

## [2026-05-01-13-00-00] - Scratchpad Management Enhancements
- **Feature**: Added a dedicated "Scratchpad Settings" menu in the command palette.
- **Improvement**: Users can now update scratchpad paths for Mac, WSL, and Linux directly from the UI.
- **Refinement**: Consolidated scratchpad path settings into a single menu entry in the Settings menu.
- **Resilience**: Improved `open_scratchpad` to handle missing files and offer to create them.
- **Fix**: Resolved compatibility issue with macOS Bash 3.2 by removing the unsupported `read -i` flag in the path update prompt.
- **Improvement**: Enhanced `dot-reload` to explicitly perform a manual Tmux configuration reload (`tmux source-file`) regardless of whether it's called from within a Tmux session, provided the server is running.
- **Refactoring**: Modularized `common/palette.sh` by splitting it into a collection of functional subscripts in `common/palette/`. This improves maintainability and organization of the command palette logic.
- **Cleanup**: Removed redundant "Open Scratchpad" and duplicate "Set Path" entries from the Scratchpad Settings menu for a cleaner UI.

## [2026-05-01-12-30-00] - Enhanced hledger Symbolic Linking & Visibility
- **Feature**: Upgraded hledger synchronization to a robust symbolic link-based approach.
- **Details**:
    - Redesigned `common/hledger-sync.sh` to move accounting data to the repository and establish a symbolic link from `~/.hledger.journal`.
    - Changed the storage filename in the repository from `.hledger.journal` (hidden) to `hledger.journal` (visible) for better discoverability.
    - Implemented automated migration logic that handles existing local files and hidden repository files.
    - This ensures all hledger data "stays" in the `Accounting-Management-System` repository for seamless cross-device synchronization via Git.
    - Updated project documentation to reflect the improved accounting integration.

## [2026-05-01-12-00-00] - hledger Journal Synchronization
- **Feature**: Automated synchronization of the `hledger` journal to the Accounting Management System repository.
- **Details**:
    - Created `common/hledger-sync.sh` to handle the conditional synchronization of `~/.hledger.journal`.
    - Integrated the sync script into `dot-sync` across all platforms (`mac`, `linux`, `wsl`).
    - The sync only triggers if the source file exists and the destination repository (`~/GitHub/INTxK/Accounting-Management-System`) is present on the system.
    - Updated `project-manager/` documentation to reflect the new accounting integration.

## [2026-04-30-12-15-00] - Micro Editor TrueColor Type Fix
- **Bug Fix**: Resolved type error for the `truecolor` setting in Micro.
- **Details**:
    - Changed `"truecolor": true` to `"truecolor": "auto"` in `common/micro/settings.json`.
    - This fixes the error message: `Error: setting 'truecolor' has incorrect type (bool), using default value: auto (string)`.

## [2026-04-30-12-00-00] - Micro Editor Cursor Visibility Fix
- **Bug Fix**: Improved cursor visibility in the Micro editor.
- **Details**:
    - Updated `common/micro/colorschemes/PolyMark.micro` to explicitly define cursor and cursor-line colors.
    - Set the cursor to Peppermint Teal (`#14b8a6`) for high contrast and focus.
    - Set the current line highlight (`cursor-line`) to Peppermint Bright Black (`#2a2a2a`) to subtly distinguish the active line without visual clutter.

## [2026-04-30-11-45-00] - Micro Editor Theme Activation
- **Feature**: Enabled the PolyMark colorscheme as the default for the Micro editor.
- **Details**:
    - Updated `common/micro/settings.json` to explicitly set `"colorscheme": "PolyMark"`.
    - Enabled `"truecolor": true` within Micro settings to ensure consistent rendering of hex colors across all platforms.
    - This ensures that the custom PolyOS aesthetic is automatically applied in Linux, WSL, and macOS environments without manual configuration.

## [2026-04-30-11-30-00] - Unified Search Discovery Scope
- **Feature**: Expanded the Command Palette search scope to include all nested items.
- **Details**:
    - Refactored `apps_menu`, `documents_menu`, `settings_menu`, and `shortcuts_menu` to support a "list-only" mode.
    - Updated `main_menu` to aggregate all leaf-node actions into the primary `fzf` instance.
    - Implemented a robust type-based dispatcher in `main_menu` to handle apps, docs, settings, and shortcuts directly from the top level.
    - Maintained hierarchical navigation via category items (Launch App..., etc.) for structured browsing.

## [2026-04-30-11-15-00] - Dynamic Project Documents Menu
- **Feature**: Replaced static "Read Manuals" with a dynamic "Project Documents" menu.
- **Details**:
    - Implemented `documents_menu` in `palette.sh` that recursively finds all `.md` files in `project-manager/`.
    - Integrated prettified display names for documentation files.
    - Updated `main_menu` to provide instant access to the full `project-manager/` document suite.
    - Standardized `glow` as the primary reader for project documentation.

## [2026-04-30-11-00-00] - Command Palette Settings & UX Preferences
- **Feature**: Implemented a "Settings" menu in the Command Palette for persistent UX configuration.
- **Details**:
    - Created `common/.polyterm_settings` to store user preferences as environment variables.
    - Added a "Settings" option (10) to the main Command Palette menu.
    - Implemented sub-menus to toggle "Security Check on Push" and "Security Check on Pull".
    - Updated `linux/zshrc`, `wsl/zshrc`, and `mac/.zshrc` to source these settings and respect the toggles in `dot-sync` and `dot-pull`.
    - Integrated a self-healing `update_setting` function in `palette.sh` for cross-platform file modification.

## [2026-04-30-10-00-00] - Homebrew Permission Fix & Chezmoi Installation
- **Bug Fix**: Resolved `Permission denied` error during Homebrew package installation on Linux.
- **Details**:
    - Identified that `/home/linuxbrew/.linuxbrew` and its subdirectories were owned by `root`, preventing the user from installing or updating packages.
    - Recursively changed ownership of the entire Homebrew installation directory to the current user (`mustafa`).
    - Successfully installed `chezmoi` via `brew install chezmoi`.
    - Documented the fix in `project-manager/issues.md`.

## [2026-04-28-13-15-00] - Comprehensive Tmux Greenish Theming
- **Feature**: Applied the unified Peppermint Teal theme to the entire Tmux interface.
- **Details**:
    - Redesigned the Tmux status bar with a modern "Powerline" aesthetic using Peppermint Teal (`#14b8a6`) and consistent Nerd Font glyphs (`󱓞`, `󱐋`, `󰃭`, `󱑎`).
    - Themed the Tmux message line (command prompt) and selection mode with high-contrast Teal.
    - Standardized window status formatting to use focal icons and subtle separators for a cleaner look.
    - Synchronized all Tmux UI elements with the master design principles in `DESIGN.md`.

## [2026-04-28-13-00-00] - Immersive Greenish Design Unification
- **Feature**: Redesigned the Command Palette and Tmux environment for a high-contrast, greenish (teal) focus.
- **Details**:
    - Updated `common/tmux.conf` to style the command palette popup with a rounded Peppermint Teal (`#14b8a6`) border and pure black background.
    - Injected a custom `fzf` theme into `common/palette.sh` that utilizes the full Peppermint palette, emphasizing Teal highlights and Green success markers.
    - Formalized the "Teal-Centric" design principles in `DESIGN.md`.
    - Synchronized component styling across Tmux popups, the Command Palette UI, and the Micro editor for a seamless, immersive terminal experience.

## [2026-04-28-12-30-00] - Project-Wide Design Unification
- **Feature**: Established a unified, bidirectionally synced design system across all applications.
- **Details**:
    - Centralized design principles in `DESIGN.md`, establishing it as the source of truth for the Peppermint palette.
    - Synchronized `common/design/peppermint.json` with the updated hex codes (e.g., Peppermint Cyan `#14b8a6`).
    - Updated `common/micro/colorschemes/PolyMark.micro` to use the standardized Peppermint hex codes.
    - Refined `common/tmux.conf` status bar to use the pure black background for a seamless "Sublime Focus" look.
    - Ensured consistent aesthetics across Glow, Command Palette, and editor environments through terminal-level color alignment.

## [2026-04-28-12-00-00] - Aesthetic Standardization with Nerd Font Glyphs
- **Feature**: Replaced all standard emojis with high-fidelity Nerd Font glyphs.
- **Details**:
    - Updated `common/palette.sh` with consistent glyphs for all menu options, prompts, and headers.
    - Standardized `common/security.sh` to use Nerd Font icons for success, warning, and error states.
    - Updated `dot-sync`, `dot-pull`, and `dot-reload` functions in `linux/zshrc`, `wsl/zshrc`, and `mac/.zshrc` to use consistent Nerd Font glyphs for feedback.
    - Improved visual hierarchy and professional appearance across the entire environment.

## [2026-04-28-11-45-00] - Self-Healing Lynis Permissions
- **Feature**: Automated resolution of Lynis file ownership issues.
- **Details**:
    - Added a self-healing step to `common/security.sh` that detects if Lynis files are not owned by root (common in Homebrew installations).
    - Automatically applies `chown root:root` to the necessary directories when run with `sudo` to satisfy Lynis's security requirements.
    - Ensures `dot-scan` can run uninterrupted during sync and pull workflows.

## [2026-04-28-11-30-00] - Continuous Security Tool Maintenance
- **Feature**: Automated installation and background updates for security tools.
- **Details**:
    - Updated all `.zshrc` files to background-upgrade `shellcheck` and `lynis` on startup.
    - Enhanced `common/security.sh` to automatically install `shellcheck` if missing.
    - Standardized `dot-sync` across all platforms to trigger `dot-scan` as the first step of the sync process.
    - Updated `project-manager/system-manual.md` to reflect the proactive maintenance of security tools.

## [2026-04-28-11-15-00] - Suppress ShellCheck Warnings in Zsh Configs
- **Bug Fix**: Resolved false positive `shellcheck` warnings for Zsh-specific syntax.
- **Details**: Added `shellcheck` disable directives (SC1091, SC2296, SC2298, SC2299) to `linux/zshrc`, `wsl/zshrc`, and `mac/.zshrc`. This allows the `dot-scan` security audit to pass while maintaining advanced Zsh path detection and sourcing logic.

## [2026-04-28-11-00-00] - Fix Lynis PATH in Security Scan
- **Bug Fix**: Resolved `sudo-rs: 'lynis': command not found` error.
- **Details**: Updated `common/security.sh` to use the absolute path of the `lynis` binary when executing with `sudo`. This prevents issues where `sudo` resets the `PATH` and cannot find Homebrew-installed tools.

## [2026-04-28-10-30-00] - Self-Healing Sync & Gemini CLI Auto-Update
- **Feature**: Implemented self-healing `dot-sync` and background Gemini CLI updates.
- **Details**:
    - Enhanced `dot-sync` across all platforms (`linux`, `wsl`, `mac`) to perform a pre-sync dependency check using `brew bundle check`.
    - Added automated healing logic to `dot-sync` that installs missing or outdated dependencies from both core and apps Brewfiles before performing a sync.
    - Integrated automatic background updates for Gemini CLI (`brew upgrade gemini-cli`) into the Zsh startup sequence of all platforms.
    - Updated `project-manager/features.md`, `project-manager/user-manual.md`, and `project-manager/tasks.md` to reflect these improvements.

## [2026-04-25-16-34-38] - Sublime Focus Aesthetic for Tmux
- **Feature**: Implemented "Sublime Focus" design system for Tmux.
- **Details**:
    - Updated `common/tmux.conf` to use a uniform pure black (`#000000`) background for all panes.
    - Set active pane border to vibrant teal (`#14b8a6`) and inactive borders to dark grey (`#2a2a2a`).
    - Disabled pane border status labels (`pane-border-status off`) for a cleaner interface.
    - Documented the design system in `DESIGN.md`.
    - Updated all project management files to reflect the aesthetic shift.

## [2026-04-25-16-16-59] - Peppermint Design System & Tmux Refinement
- **Feature**: Centralized design system and Peppermint theme integration.
- **Details**:
    - Created `DESIGN.md` in the root to define core design principles and color palette.
    - Moved `peppermint.json` to `common/design/` for centralized access.
    - Reverted tmux heavy borders and border status padding.
    - Applied Peppermint colors to Tmux: solid black (`#000000`) active background, dimmed (`#1c1c1c`) inactive background, and blue (`#449fd0`) active borders.
    - Aligned Tmux status bar with Peppermint palette.
    - Updated all project management files to reflect the new design system.

## [2026-04-25-15-55-22] - Tmux Pane Ergonomics
- **Feature**: Implemented pane padding and visual differentiation.
- **Details**:
    - Added `window-style` and `window-active-style` to dim inactive panes (using Catppuccin Mantle).
    - Enabled `pane-border-lines heavy` for better visual separation.
    - Configured `pane-border-status top` with empty padding to create visual "air" at the top of panes.
    - Updated `common/tmux.conf` and all project management files.

## [2026-04-25] 🐚 Global Shellcheck Resolution & Script Robustness
- **Feature**: Achieved 100% compliance with `shellcheck` across all repository scripts and configurations.
- **Changes**:
  - Refactored `common/security.sh` to use robust `while read` loops for file scanning, preventing issues with paths containing spaces.
  - Updated `common/palette.sh` with safe array population and consistent variable quoting.
  - Optimized `application-package/install.sh` for portability by replacing `read -p` with `printf` and `read -r`.
  - Added `shellcheck` dialect hints to all Zsh configuration files (`.zshrc`) to ensure accurate static analysis.
  - Consistently quoted all variable expansions to prevent word splitting and globbing issues.
- **Impact**: Eliminates all security scan warnings related to shell script vulnerabilities and significantly improves the reliability of automation scripts across different platforms.

## [2026-04-25] 🧹 Zsh Configuration Cleanup & Tmux Error Resolution
- **Feature**: Fixed configuration corruption that caused shell errors.
- **Changes**:
  - Cleaned up `mac/.zshrc` by removing corrupted trailing lines that caused the shell to misinterpret the configuration.
  - Cleaned up `linux/zshrc` by removing duplicate plugin sourcing and path exports.
- **Impact**: Resolves the "command not found" and "parse error" messages seen when the shell incorrectly attempted to execute `.tmux.conf` as a script.

## [2026-04-25] 🛡️ Hardened Secret Detection & False Positive Reduction
- **Feature**: Refined the repository's secret scanning heuristic to be more accurate and less noisy.
- **Changes**:
  - Updated `dot-scan` in `common/security.sh` to exclude the scanner script itself and common system environment variables (`SSH_AUTH_SOCK`, `COLORTERM`, `MICRO_TRUECOLOR`).
  - Improved exclusion patterns to ignore comments and descriptive text.
  - Performed a full repository audit to ensure no actual hardcoded credentials exist.
- **Impact**: Provides a cleaner, more reliable security report while maintaining high sensitivity for actual hardcoded secrets.

## [2026-04-25] 🛡️ Automatic Security Tool Installation
- **Feature**: Ensured critical security tools are available before scanning.
- **Changes**:
  - Updated `dot-scan` in `common/security.sh` to automatically install `lynis` via Homebrew if it's not found in the path.
- **Impact**: Guarantees that system security audits are never skipped due to missing dependencies, maintaining a consistent security baseline across all environments.

## [2026-04-25] 🌍 OS Environment Standardization & Brewfile Path Fix
- **Feature**: Standardized the `OS_ENV` variable across all platforms to ensure robust path resolution for Homebrew dependencies.
- **Changes**:
  - Exported `OS_ENV="wsl"` in `wsl/zshrc` to fix the "No Brewfile found" error during `dot-pull`.
  - Exported `OS_ENV="linux"` in `linux/zshrc` for generic Linux environments.
  - Exported `OS_ENV="mac"` in `mac/.zshrc` and updated `dot-sync` and `dot-pull` functions to use the variable instead of hardcoded paths.
  - Cleaned up the repository by removing a misplaced `Brewfile.apps` file in the root directory that was created by previous failed sync attempts.
- **Impact**: Resolves critical path resolution issues in automation scripts, ensuring that `dot-pull` and `dot-sync` correctly identify platform-specific configuration files.

## [2026-04-25] 🛡️ Security Vulnerability Scanning & Automated Fixes
- **Feature**: Integrated security auditing and remediation into the dotfile lifecycle.
- **Changes**:
  - Created `common/security.sh` containing the `dot-scan` function for multi-layered security audits.
  - Integrated `shellcheck` for static analysis of shell scripts and Zsh profiles.
  - Implemented automated package upgrades via `brew outdated` to fix known vulnerabilities.
  - Added Homebrew health monitoring with `brew doctor`.
  - Implemented heuristic scanning for hardcoded secrets (API keys, tokens).
  - Integrated `lynis` for deep system-level security auditing.
  - Embedded `dot-scan` into `install.sh` (initial setup), `dot-pull` (post-update), and `dot-sync` (pre-sync).
  - Added `shellcheck` and `lynis` to `Brewfile.core` across all platforms.
- **Impact**: Provides a robust, proactive security posture for the user's environment, ensuring vulnerabilities are detected and addressed automatically.

## [2026-04-25] 🧩 Interactive Optional App Selection
- **Feature**: Provided users with the choice to install optional applications during setup.
- **Changes**:
  - Split Brewfiles into `Brewfile.core` (essentials) and `Brewfile.apps` (optional) for all platforms.
  - Updated `application-package/install.sh` with an `fzf`-powered interactive multi-select menu.
  - Enhanced `dot-sync` to intelligently maintain the split by filtering dumped items against the core list.
  - Re-targeted the Command Palette (`palette.sh`) to use `Brewfile.apps` for its interactive menu.

## [2026-04-25] 📢 Default Verbosity for Setup & Sync
- **Feature**: Standardized verbose output across all installation and synchronization workflows.
- **Changes**:
  - Added `--verbose` flag to `brew bundle` in `application-package/install.sh`.
  - Added `--verbose` flag to `git push` and `git pull` in `dot-sync` and `dot-pull` shell functions across all platforms.
  - Verified that palette-based installations and removals already use the `--verbose` flag.

## [2026-04-25] 🎨 Automated Theme & Font Deployment
- **Feature**: Ensured all visual components (Catppuccin, PolyMark, Nerd Fonts) are automatically configured.
- **Changes**:
  - Added automated **JetBrains Mono Nerd Font** installation for Linux and WSL in `install.sh`.
  - Added `unzip` dependency to Linux/WSL Brewfiles to support font extraction.
  - Verified that `mac/Brewfile` already includes the font cask.
  - Confirmed that **Catppuccin** (Tmux) and **PolyMark** (Micro) themes are correctly deployed via symlinks and TPM.

## [2026-04-25] 📝 Content Wrapping Improvements
- **Feature**: Enabled default content wrapping for `tmux`, `micro`, and `glow`.
- **Changes**:
  - Configured `micro` with `"softwrap": true` in `common/micro/settings.json`.
  - Configured `glow` with `width: 80` in `common/glow.yml` and added a shell alias `glow -w 80`.
  - Added explicit `wrap-search` option in `common/tmux.conf` (though tmux wraps content by default).
  - Updated `install.sh` to symlink the new `glow.yml` configuration.

## [2026-04-25] 🍺 PolyTerm CLI & Homebrew Tap Support
- **Feature**: Enabled `brew install polyterm` by implementing a Homebrew formula and a centralized CLI tool.
- **Changes**:
  - Developed `bin/polyterm` bash script with subcommands for `setup`, `sync`, `pull`, and `reload`.
  - Created `Formula/polyterm.rb` to turn the repository into a functional Homebrew Tap.
  - Configured `polyterm` to launch the Command Palette by default when run inside Tmux.
  - Updated project documentation to reflect the new CLI-based management workflow.

## [2026-04-25] 🚀 Unified Application Package & One-Command Installation
- **Feature**: Implemented a "single command" installation experience for macOS, WSL, and Linux.
- **Changes**:
  - Created `application-package/install.sh` bootstrap script for automated environment setup.
  - Added generic Linux support by creating `linux/zshrc` and updating `Brewfile` logic.
  - Enhanced `dot-sync` and `dot-pull` in both `wsl/zshrc` and `linux/zshrc` to robustly handle multiple OS environments.
  - Configured `install.sh` to handle Homebrew installation, repository cloning, config backups, symlinking, and TPM setup.
  - Enabled remote installation support via `curl | bash`.

## [2026-04-22] 📂 Path Relativeization & Portability
- **Feature**: Converted all hardcoded repository paths to dynamic, relative paths.
- **Changes**:
  - Updated `common/palette.sh` to derive `REPO_PATH` dynamically from the script's location.
  - Enhanced `mac/.zshrc` and `wsl/zshrc` to dynamically determine `DOTFILES_ROOT` based on the sourced file's location.
  - Configured `zshrc` to export `DOTFILES_ROOT` to the Tmux environment using `tmux set-environment`.
  - Refactored `common/tmux.conf` to use the `$DOTFILES_ROOT` environment variable for the Command Palette binding.
  - Updated all shell functions (`dot-sync`, `dot-pull`) to use the dynamic `DOT_PATH` instead of hardcoded home directory paths.
- **Impact**: The repository can now be cloned to any directory (e.g., `~/dotfiles`, `~/GitHub/dotfiles`, `~/Developer/my-configs`) without breaking the automation scripts or keybindings.

## [2026-04-22] 🛠️ Tmux Configuration Protection & User Guidance
- **Issue**: Users were accidentally running `~/.tmux.conf` as a shell script, resulting in "command not found" and "parse error" messages.
- **Changes**:
  - Added a protective warning comment to the header of `common/tmux.conf` clarifying that it is NOT a shell script.
  - Provided explicit instructions on the correct methods for reloading configuration (`dot-reload`, `tmux source-file`, or `Alt+r`).
- **Impact**: Reduces user confusion and prevents common misconfiguration errors during the dotfile development lifecycle.

## [2026-04-21]   Unified Alt Key Shortcuts (Cross-Platform)
- **Feature**: Standardized all Tmux and Command Palette shortcuts to use the `Alt` (Meta) key globally.
- **Changes**:
  - Removed OS-specific conditional logic in `common/tmux.conf`, favoring `M-` (Meta) bindings for all platforms.
  - Simplified `common/palette.sh` to consistently display and execute `Alt` shortcuts.
  - Enhanced `common/fix-alt-keys.sh` with a diagnostic "Test Mode" and detailed instructions for configuring GNOME Terminal (Ubuntu) and iTerm2/Terminal.app (macOS).
- **Impact**: Provides a consistent, muscle-memory-friendly experience across WSL, Ubuntu, and Mac, provided the terminal is configured to pass Alt as Meta.

## [2026-04-21]   Conditional Ctrl+Shift Shortcuts (macOS & Ubuntu)
- **Feature**: Switched all custom Tmux shortcuts to `Ctrl+Shift` for Mac and Ubuntu to avoid `Alt` key hardware/terminal conflicts.
- **Changes**:
  - Modified `common/tmux.conf` to use `if-shell` OS detection.
  - Implemented `Ctrl+Shift` (e.g., `C-P`, `C-S-Up`) for Mac/Ubuntu.
  - Retained `Alt` (e.g., `M-p`, `M-Up`) for WSL where it remains native and working.
  - Dynamically updated `common/palette.sh` to show the correct modifier in the Help menu based on the current OS.
- **Impact**: Provides a reliable way to trigger the palette and manage windows/panes without terminal intercept issues.

## [2026-04-20] 🛠️ Tmux Initialization Robustness & Bug Fix
- **Feature**: Improved Tmux auto-start logic to prevent terminal-related errors.
- **Changes**:
  - Modified `wsl/zshrc` and `mac/.zshrc` to wrap the Tmux initialization in an interactivity check (`[[ -o interactive ]]`).
  - Added `2>/dev/null` to the `tmux attach-session` command to suppress "can't find session: default" noise during fresh starts.
- **Impact**: Resolves "open terminal failed: not a terminal" and "can't find session: default" errors when opening the terminal, particularly in environments like VS Code or non-interactive shell invocations.

## [2026-04-20] 🚀 Automated Shell & Cockpit Launch
- **Feature**: Automatic initialization of Zsh and Tmux upon terminal startup.
- **Changes**:
  - Modified `~/.bashrc` to automatically `exec zsh` in interactive sessions, ensuring Zsh becomes the primary shell without requiring system-level `chsh` changes.
  - Verified the existing "TMUX COCKPIT INITIALIZATION" logic in `wsl/zshrc` which auto-attaches or creates a 'default' tmux session.
- **Impact**: Provides a frictionless "instant-on" experience where the user is immediately dropped into their configured Zsh + Tmux environment.

## [2026-04-20] 🛠️ WSL Dotfiles Deployment & Sync
- **Feature**: Deployment of repository configurations to the local WSL environment (Surface Pro 3).
- **Changes**:
  - Updated `common/tmux.conf` to use absolute paths for the command palette script.
  - Backed up existing `~/.zshrc` and `~/.config/micro` to `.bak` files.
  - Created symbolic links for `~/.zshrc`, `~/.tmux.conf`, and `~/.config/micro` pointing to the repository.
  - Installed Tmux Plugin Manager (TPM) and Homebrew dependencies from `wsl/Brewfile`.
  - Installed `zsh-syntax-highlighting` via apt to resolve missing dependency in Zsh.
  - Verified `fzf` and `xclip` availability for palette and clipboard functionality.
- **Impact**: The WSL environment is now fully synchronized with the repository and the latest configuration standards.

## [2026-04-20] 🛠️ Project State Verification & Documentation Sync
- **Feature**: Routine maintenance and documentation alignment.
- **Changes**:
  - Verified cross-platform consistency across macOS (MacBook Pro) and WSL (Surface Pro 3).
  - Synchronized `project-manager/` files to reflect the 100% completion of defined tasks.
  - Updated `tasks.md` to mark the PolyMark Translation section as fully completed.
  - Audited `mac/Brewfile` and `wsl/Brewfile` for consistency; noted additional dev tools (Rust, Python 3.14, Zoxide) on the macOS environment.
- **Impact**: Ensures that Gemini CLI and the user have an accurate, up-to-date view of the project's progress and environment state.

## [2026-04-19] 🍏 macOS Dotfiles Deployment & Sync
- **Feature**: Initial deployment of repository configurations to the local macOS environment.
- **Changes**:
  - Created symbolic link from repo to `~/dotfiles` to maintain path consistency with automation scripts.
  - Backed up existing `~/.zshrc` and `~/.tmux.conf` to `.bak` files.
  - Deployed `mac/.zshrc`, `common/tmux.conf`, and `common/micro/` to their respective local settings paths via symbolic links.
  - Successfully executed the first `dot-sync` on macOS, which refreshed the `mac/Brewfile` and pushed all configuration changes to GitHub.
- **Impact**: The Mac environment is now fully synchronized with the repository, enabling unified cross-platform management.

## [2026-04-18] 🔄 Integrated Configuration Reloading
- **Feature**: Unified command and shortcuts to refresh the entire environment.
- **Changes**:
  - Implemented `dot-reload` function in both `mac/.zshrc` and `wsl/zshrc` to source Zsh config and reload Tmux config.
  - Added `Alt+r` global keybinding in `common/tmux.conf` to trigger `dot-reload` in the current pane.
  - Updated `common/palette.sh` to include "Reload All Configs" option, replacing the Tmux-only refresh.
  - Unified reloading logic across terminal prompt, keybindings, and command palette.
- **Impact**: Provides a seamless way to apply configuration changes instantly without restarting sessions or windows.

## [2026-04-17] 🏎️ Homebrew Performance Optimization
- **Feature**: Faster installations by disabling automatic post-install cleanup.
- **Changes**:
  - Exported `HOMEBREW_NO_INSTALL_CLEANUP=1` in both `wsl/zshrc` and `mac/.zshrc`.
  - Documented the `brew bundle dump` performance issue for further investigation.
- **Impact**: Significant reduction in time for `brew install` and `brew uninstall` operations.

## [2026-04-17] ⚡ Optimized App Description Loading
- **Feature**: Instant loading of the "Launch App" menu when descriptions are cached.
- **Changes**:
  - Refactored `apps_menu` in `common/palette.sh` to use `awk` for high-speed list generation.
  - Implemented a "fetch-on-demand" logic that only triggers the "Loading..." message and `brew info` when an app is missing from `apps_meta.txt`.
  - Eliminated the per-app `grep` loop, significantly improving responsiveness for large Brewfiles.
- **Impact**: The Command Palette now opens the app list instantly if all blurbs are cached.

## [2026-04-17] 📢 Verbose Installation & Syncing
- **Feature**: Enhanced transparency for installation and synchronization processes.
- **Changes**:
  - Added `--verbose` flag to `brew bundle` and `brew bundle dump` in `wsl/zshrc` and `mac/.zshrc`.
  - Added `--verbose` flag to `brew install` and `brew uninstall` in `common/palette.sh`.
  - Aligned `mac/.zshrc` with `wsl/zshrc` by adding `dot-sync` and enhancing `dot-pull` with `brew bundle`.
  - Updated `project-manager/tasks.md` to reflect the changes.
- **Impact**: Provides users with detailed real-time feedback during package management and dotfile synchronization.

## [2026-04-17] 🚀 Smart Brewfile Sync & Command Palette Integration
- **Feature**: Automated Homebrew dependency management.
- **Changes**:
  - Updated `wsl/zshrc` with enhanced `dot-sync` and `dot-pull` functions.
  - `dot-sync` now automatically runs `brew bundle dump` to refresh Brewfiles before pushing to GitHub.
  - `dot-pull` now automatically runs `brew bundle` to install new dependencies after pulling from GitHub.
  - Modified `common/palette.sh` to support cross-platform repository paths.
  - Integrated `dot-sync` directly into "Install" and "Uninstall" workflows in the Command Palette.
  - Updated `project-manager/` documentation (`features.md`, `tasks.md`, `plan.md`).
  - Created `GEMINI.md` with repository-specific instructions and documentation standards.
- **Platform**: Verified for WSL/Ubuntu and structured for macOS compatibility.

## [2026-04-17] ✨ Dynamic App Descriptions in Palette
- **Feature**: Command Palette now shows descriptions for CLI tools.
- **Changes**:
  - Enhanced `get_app_description` in `common/palette.sh` to fetch descriptions using `brew info`.
  - Implemented caching to `apps_meta.txt` to ensure fast loading in subsequent uses.
  - Added "Loading..." indicator to `apps_menu` while fetching metadata.
  - Added automatic cleanup of metadata upon uninstallation.
  - Updated documentation (`features.md`, `tasks.md`, `plan.md`).
- **Impact**: Improved user experience when browsing and launching tools from the palette.

## [2026-04-17] 🎹 Session Management & Shortcuts Reference
- **Feature**: Enhanced Tmux navigation and internal documentation.
- **Changes**:
  - Added `Alt+,` to create new sessions and `Alt+0` to cycle through active sessions in `common/tmux.conf`.
  - Implemented a "Shortcuts Reference" menu in `common/palette.sh` that lists all custom keybindings.
  - Re-indexed the main menu in the Command Palette to accommodate the new reference option.
  - Updated documentation (`features.md`, `tasks.md`, `plan.md`).
- **Impact**: Increased productivity through faster session switching and better discoverability of custom bindings.

## [2026-04-17] ⚡ Executable Shortcuts & Session Termination
- **Feature**: Interactive palette and expanded session control.
- **Changes**:
  - Added `Alt+w` to kill the current session in `common/tmux.conf`.
  - Upgraded the "Shortcuts Reference" in `common/palette.sh` to an **"Execute Shortcut"** menu.
  - Mapped menu items to actual `tmux` commands using `tmux run-shell`.
  - Added session termination to both keybindings and the palette menu.
  - Updated documentation (`features.md`, `tasks.md`, `plan.md`).
- **Impact**: Provides a powerful GUI-like command execution layer for Tmux management.

## [2026-04-17] 🛡️ Ergonomics & Safety Improvements
- **Feature**: Refined UX for the Command Palette.
- **Changes**:
  - Standardized emoji spacing (two spaces after each emoji) for consistent alignment across terminals.
  - Implemented a `confirm_action` helper function in `common/palette.sh`.
  - Added "Are you sure?" confirmation prompts for uninstalling apps and killing sessions.
  - Improved `fzf` prompt and header text for better clarity.
  - Updated documentation (`features.md`, `tasks.md`, `plan.md`).
- **Impact**: Reduced risk of accidental destructive actions and improved overall visual consistency.

## [2026-04-17] 🎨 Nerd Font Integration
- **Feature**: Modernized UI with vector-like glyphs.
- **Changes**:
  - Replaced all standard emojis in `common/palette.sh` with specific Nerd Font v3 symbols.
  - Standardized symbols for Launch, Install, Uninstall, Shortcuts, Sync, and System commands.
  - Maintained consistent spacing and alignment for a high-end CLI aesthetic.
  - Updated documentation (`features.md`, `tasks.md`, `plan.md`).
- **Impact**: More professional and consistent visual experience across various terminal fonts that support Nerd Fonts.
