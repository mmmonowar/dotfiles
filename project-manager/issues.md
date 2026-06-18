# Project Issues

## [ISSUE-01] ✅ Tmux Sourcing & Selection Issues
- **Status**: Resolved
- **Description**: Sourcing `.tmux.conf` resulted in syntax errors (early expansion of `$(...)`) and `Shift+Arrow` selection/`Ctrl+c` copy didn't always take effect.
- **Resolution**: Fixed `M-1` binding by using single quotes to delay shell expansion. Refined `is_editor` detection for better macOS compatibility. Added explicit `copy-mode-vi` bindings for `Shift+Arrows` to ensure seamless selection.

## [ISSUE-02] ✅ Micro PolyMark Theme Missing (Linux)
- **Status**: Resolved
- **Description**: The PolyMark colorscheme was present in the repository but not activated by default in the Micro editor, leading to it appearing "missing" on Linux.
- **Resolution**: Updated `common/micro/settings.json` to explicitly set `colorscheme: PolyMark` and enable `truecolor: "auto"` for consistent cross-platform activation.

## [ISSUE-03] ✅ Homebrew Permission Denied (Linux)
- **Status**: Resolved
- **Description**: `brew install` fails with `Permission denied` when trying to rename files in `/home/linuxbrew/.linuxbrew/Cellar` or temp directories.
- **Resolution**: Changed ownership of `/home/linuxbrew/.linuxbrew` and all its subdirectories to the current user (`mustafa`) using `sudo chown -R $(whoami) /home/linuxbrew/.linuxbrew`.

## [ISSUE-04] ✅ Tmux Initialization Errors
- **Status**: Resolved
- **Description**: Terminal displays "can't find session: default" and "open terminal failed: not a terminal" upon startup.
- **Resolution**: Added interactivity check `[[ -o interactive ]]` and suppressed stderr for the initial attach attempt in `.zshrc`.

## [ISSUE-05] ✅ Slow Homebrew Installations (Cleanup)
- **Status**: Resolved
- **Description**: `brew install` triggers an automatic cleanup process that takes a significant amount of time.
- **Resolution**: Set `HOMEBREW_NO_INSTALL_CLEANUP=1` in `.zshrc` to disable automatic cleanup after every installation.

## [ISSUE-06] ✅ Alt Key Compatibility (macOS & Ubuntu)
- **Status**: Resolved
- **Description**: Alt/Option shortcuts (like Alt+p) were not registered by Tmux.
- **Resolution**: 
    - Implemented `common/fix-alt-keys.sh` which automates the disabling of GNOME Terminal menu accelerators on Ubuntu.
    - Provided clear in-terminal instructions for configuring macOS Terminal.app and iTerm2 to use "Option as Meta".
    - Added a "Fix Alt Keys" entry to the Command Palette for instant troubleshooting.

## [ISSUE-07] ✅ Cargo Shared Library Error (libllhttp)
- **Status**: Resolved
- **Description**: `cargo` failed with `libllhttp.so.9.3: cannot open shared object file` after a background Homebrew update.
- **Resolution**: Upgraded and reinstalled `libgit2` (which depends on `llhttp`) and `rust`. This correctly linked the binaries to the newer `llhttp` version (9.4.1) and resolved the dependency mismatch.

## [ISSUE-08] ✅ Zsh Regex Module Load Error (WSL)
- **Status**: Resolved
- **Description**: Zsh failed to load module `zsh/regex` with `cannot open shared object file: No such file or directory` or looking for `regex.bundle` instead of a `.so` file on WSL. This is usually caused by a stale completion cache after a Homebrew Zsh upgrade.
- **Resolution**: Cleared the corrupted cache using `rm -f ~/.zcompdump*` and restarted the shell using `exec zsh`. If the issue persists, `brew reinstall zsh` ensures the modules are correctly placed.

## [ISSUE-09] ✅ Security Scanner Sourcing Inconsistency
- **Status**: Resolved
- **Description**: The `dot-scan` security scanner function was sourced in `wsl/zshrc` but was entirely missing from `mac/.zshrc` and `linux/zshrc`. As a result, running `dot-scan` or performing pre-sync scans failed on macOS and native Linux with `command not found: dot-scan`.
- **Resolution**: Sourced `common/security.sh` in both `mac/.zshrc` and `linux/zshrc` right before the `dot-sync` function, standardizing availability across all environments.

## [ISSUE-10] ✅ macOS Installer Crash (mapfile command not found)
- **Status**: Resolved
- **Description**: The unified installer `application-package/install.sh` uses `mapfile` on line 133 to read the selected apps. However, `mapfile` is a Bash 4.0+ feature, whereas macOS's default shell `/bin/bash` is version 3.2. Running the installer on a fresh Mac fails with `install.sh: line 133: mapfile: command not found`.
- **Resolution**: Replaced the `mapfile` command with a standard `while read -r` loop that appends items to the `all_apps` array, ensuring compatibility with macOS's stock Bash 3.2 shell.

## [ISSUE-11] ✅ Unsafe Global Shortcut in Tmux (Alt+r)
- **Status**: Resolved
- **Description**: Sourcing `tmux.conf` sets up a global shortcut `bind-key -n M-r send-keys "source ~/.zshrc && dot-reload" C-m` that executes `dot-reload` by sending keys directly to the active pane. If `Alt+r` is pressed while editing a file in `micro` or `vim`, or running an interactive command, the reload text will be written directly into the file buffer, causing potential code corruption.
- **Resolution**: Guarded the shortcut in `common/tmux.conf` using the `is_editor` helper. If an editor is active, `Alt+r` keys are forwarded to the editor; otherwise, the shell reload command is executed safely.

## [ISSUE-12] 🛠️ Broken Operator Precedence in Security Scanner find Command
- **Status**: Active
- **Description**: In `common/security.sh`, the shell script scanner evaluates file paths using: `find "$DOT_PATH" -maxdepth 3 -name "*.sh" -o -name "*zshrc" -not -path "*/.git/*"`. Because the `-o` operator has lower precedence than implicit `-and`, this is evaluated as `( -name "*.sh" ) OR ( -name "*zshrc" -not -path "*/.git/*" )`, which causes `.sh` files inside `.git` directories to be processed incorrectly.
- **Proposed Resolution**: Add parentheses to group the search patterns: `\( -name "*.sh" -o -name "*zshrc" \)`.

## [ISSUE-13] ✅ Slow macOS Shell Startup (brew --prefix evaluation)
- **Status**: Resolved
- **Description**: Sourcing `zsh-syntax-highlighting` in `mac/.zshrc` uses `$(brew --prefix)/share/zsh-syntax-highlighting/...`. Sourcing this executes the `brew` command, which starts a Ruby interpreter and takes 100-200ms, noticeably slowing down terminal startup time.
- **Resolution**: Replaced the dynamic `brew --prefix` subshell execution in `mac/.zshrc` with static fallback paths (checking `/opt/homebrew` and `/usr/local` directly first), falling back to dynamic search only if static paths are missing.

## [ISSUE-14] ✅ Cask and tap package omission in Command Palette Uninstall Menu
- **Status**: Resolved
- **Description**: The Command Palette uninstall function (`uninstall_app` in `common/palette/apps.sh`) queries `Brewfile.apps` using `grep '^brew "'`, which matches standard Homebrew formulae but entirely omits `cask` packages (e.g., `cask "keepassxc"`) and tap packages with additional options, making them unmanageable through the palette.
- **Resolution**: Rewrote `common/palette/apps.sh` to extract both `brew` and `cask` entries from `Brewfile.apps`, splitting them by type. Modified dynamic description fetching, launch scripts (using `open -a` for macOS casks to launch them in the background), and uninstallation commands (`brew uninstall --cask`) to fully support casks.

## [ISSUE-15] 🛠️ Redundant Catppuccin Plugin in Tmux Configuration
- **Status**: Active
- **Description**: Although the environment has migrated to the custom Peppermint Design System, `common/tmux.conf` still references `set -g @plugin 'catppuccin/tmux'` on line 189, adding unnecessary startup latency and potential visual styling conflicts.
- **Proposed Resolution**: Remove the unused `catppuccin/tmux` plugin reference.

## [ISSUE-16] ✅ Fragile Relative Symlink Resolution in PolyTerm CLI
- **Status**: Resolved
- **Description**: In `bin/polyterm`, symlink path resolution only handles single-level symlinks and will fail to resolve the absolute `REPO_PATH` if the script is symlinked using relative paths.
- **Resolution**: Implemented a recursive symlink resolution loop `while [[ -h "$SOURCE" ]]` in `bin/polyterm` to trace and resolve nested and relative symlinks robustly.

## [ISSUE-17] 🛠️ Redundant Wrapping in Tmux Shortcuts Menu
- **Status**: Active
- **Description**: `execute_shortcut` inside `common/palette/shortcuts.sh` executes commands using `tmux run-shell "tmux $cmd"`. Spawning `tmux run-shell` to run `tmux` internally is highly redundant and slow (spawns 3 processes instead of 1).
- **Proposed Resolution**: Run `tmux $cmd` directly in the shell.

## [ISSUE-18] ✅ Configuration Desynchronization between Homebrew PolyTerm and dotfiles Repo
- **Status**: Resolved
- **Description**: When `polyterm` is installed via Homebrew Tap, its binary (`/opt/homebrew/bin/polyterm`) resolves `REPO_PATH` to the Homebrew cellar prefix `/opt/homebrew/Cellar/polyterm/<version>/`. When the user runs `polyterm` from the CLI:
  1. It reads/writes settings (`.polyterm_settings`) to the Homebrew prefix copy instead of the user's active dotfiles repository (`~/dotfiles/common/.polyterm_settings`).
  2. It reads `Brewfile.apps` and caches app descriptions in `apps_meta.txt` inside the Homebrew cellar prefix instead of `~/dotfiles`.
  This causes a desynchronization where the CLI-launched Command Palette and the Tmux-launched Command Palette (`Alt+p` which uses `$DOTFILES_ROOT`) have completely separate state, and CLI settings changes are not tracked by Git or pushed during `dot-sync`.
- **Resolution**: Updated `bin/polyterm` and `common/palette.sh` to check if a user-controlled active repository directory exists (at `$DOTFILES_ROOT` or fallback `~/dotfiles`) with a valid `/common/palette` library folder, prioritizing it as `REPO_PATH` over the Homebrew cellar prefix folder.
