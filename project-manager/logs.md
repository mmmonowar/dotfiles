# Project Logs

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
