## ✅ Path Confusion & Naming Inconsistency
- **Status**: Resolved
- **Description**: Inconsistent naming (hidden `.zshrc` in repo vs visible `zshrc`) and hardcoded installer paths caused duplicate repository clones and user confusion.
- **Resolution**:
    - Unified all repository configuration sources to be visible files (e.g., `mac/zshrc`, `common/polyterm_settings`).
    - Enhanced `application-package/install.sh` to automatically detect if it is running from within an existing repository.
    - Standardized the bootstrap process to respect the current repository location, preventing duplicate clones to `~/dotfiles`.
    - Updated all internal references in Zsh profiles and the Command Palette to the new visible filenames.

## [ISSUE-01] ✅ Tmux Sourcing & Selection Issues
- **Status**: Resolved
- **Description**: Sourcing `.tmux.conf` resulted in syntax errors (early expansion of `$(...)`) and `Shift+Arrow` selection/`Ctrl+c` copy didn't always take effect.
- **Resolution**: Fixed `M-1` binding by using single quotes to delay shell expansion. Refined `is_editor` detection for better macOS compatibility. Added explicit `copy-mode-vi` bindings for `Shift+Arrows` to ensure seamless selection.

## [ISSUE-02] ✅ Micro PolyMark Theme Missing (Linux)
- **Status**: Resolved
- **Description**: The PolyMark colorscheme was present in the repository but not activated by default in the Micro editor, leading to it appearing "missing" on Linux.
- **Resolution**: Updated `common/micro/settings.json` to explicitly set `colorscheme: PolyMark` and enable `truecolor: "auto"` for consistent cross-platform activation.

## [ISSUE-03] ✅ Homebrew Permission Denied (Linux)
>>>>>>> refs/remotes/origin/main
- **Status**: Resolved
- **Description**: `brew install` failed with `Permission denied` because a security scan script incorrectly chowned the Homebrew root to `root:root`. Additionally, hardcoded user paths in settings broke portability for different developers.
- **Resolution**: 
    - Restored Homebrew ownership to the current user.
    - Updated `common/security.sh` with adaptive "self-healing" that ensures the *active* user owns Homebrew, instead of forcing it to root.
    - Converted all hardcoded paths in `common/.polyterm_settings` to use the `$HOME` environment variable.
    - Enhanced the Command Palette's `update_setting` function to automatically preserve `$HOME` when saving paths, ensuring the configuration remains portable across all devices and users.

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

## [ISSUE-12] ✅ Broken Operator Precedence in Security Scanner find Command
- **Status**: Resolved
- **Description**: In `common/security.sh`, the shell script scanner evaluates file paths using: `find "$DOT_PATH" -maxdepth 3 -name "*.sh" -o -name "*zshrc" -not -path "*/.git/*"`. Because the `-o` operator has lower precedence than implicit `-and`, this was evaluated as `( -name "*.sh" ) OR ( -name "*zshrc" -not -path "*/.git/*" )`, which caused `.sh` files inside `.git` directories to be processed incorrectly.
- **Resolution**: Parentheses were added to group the search patterns `\( -name "*.sh" -o -name "*zshrc" \)` inside `common/palette/security.sh` to enforce correct operator precedence.

## [ISSUE-13] ✅ Slow macOS Shell Startup (brew --prefix evaluation)
- **Status**: Resolved
- **Description**: Sourcing `zsh-syntax-highlighting` in `mac/.zshrc` uses `$(brew --prefix)/share/zsh-syntax-highlighting/...`. Sourcing this executes the `brew` command, which starts a Ruby interpreter and takes 100-200ms, noticeably slowing down terminal startup time.
- **Resolution**: Replaced the dynamic `brew --prefix` subshell execution in `mac/.zshrc` with static fallback paths (checking `/opt/homebrew` and `/usr/local` directly first), falling back to dynamic search only if static paths are missing.

## [ISSUE-14] ✅ Cask and tap package omission in Command Palette Uninstall Menu
- **Status**: Resolved
- **Description**: The Command Palette uninstall function (`uninstall_app` in `common/palette/apps.sh`) queries `Brewfile.apps` using `grep '^brew "'`, which matches standard Homebrew formulae but entirely omits `cask` packages (e.g., `cask "keepassxc"`) and tap packages with additional options, making them unmanageable through the palette.
- **Resolution**: Rewrote `common/palette/apps.sh` to extract both `brew` and `cask` entries from `Brewfile.apps`, splitting them by type. Modified dynamic description fetching, launch scripts (using `open -a` for macOS casks to launch them in the background), and uninstallation commands (`brew uninstall --cask`) to fully support casks.

## [ISSUE-15] ✅ Redundant Catppuccin Plugin in Tmux Configuration
- **Status**: Resolved
- **Description**: Although the environment has migrated to the custom Peppermint Design System, `common/tmux.conf` still referenced `set -g @plugin 'catppuccin/tmux'` on line 189, adding unnecessary startup latency and potential visual styling conflicts.
- **Resolution**: Removed the unused and redundant `catppuccin/tmux` plugin reference from `common/config/tmux/tmux.conf`.

## [ISSUE-16] ✅ Fragile Relative Symlink Resolution in PolyTerm CLI
- **Status**: Resolved
- **Description**: In `bin/polyterm`, symlink path resolution only handles single-level symlinks and will fail to resolve the absolute `REPO_PATH` if the script is symlinked using relative paths.
- **Resolution**: Implemented a recursive symlink resolution loop `while [[ -h "$SOURCE" ]]` in `bin/polyterm` to trace and resolve nested and relative symlinks robustly.

## [ISSUE-17] ✅ Redundant Wrapping in Tmux Shortcuts Menu
- **Status**: Resolved
- **Description**: `execute_shortcut` inside `common/palette/shortcuts.sh` executed commands using `tmux run-shell "tmux $cmd"`. Spawning `tmux run-shell` to run `tmux` internally is highly redundant and slow (spawns 3 processes instead of 1).
- **Resolution**: Rewrote `execute_shortcut` in `common/palette/shortcuts.sh` to execute the tmux commands directly via shell evaluation (`eval "tmux $cmd"`).

## [ISSUE-18] ✅ Configuration Desynchronization between Homebrew PolyTerm and dotfiles Repo
- **Status**: Resolved
- **Description**: When `polyterm` is installed via Homebrew Tap, its binary (`/opt/homebrew/bin/polyterm`) resolves `REPO_PATH` to the Homebrew cellar prefix `/opt/homebrew/Cellar/polyterm/<version>/`. When the user runs `polyterm` from the CLI:
  1. It reads/writes settings (`.polyterm_settings`) to the Homebrew prefix copy instead of the user's active dotfiles repository (`~/dotfiles/common/.polyterm_settings`).
  2. It reads `Brewfile.apps` and caches app descriptions in `apps_meta.txt` inside the Homebrew cellar prefix instead of `~/dotfiles`.
  This causes a desynchronization where the CLI-launched Command Palette and the Tmux-launched Command Palette (`Alt+p` which uses `$DOTFILES_ROOT`) have completely separate state, and CLI settings changes are not tracked by Git or pushed during `dot-sync`.
- **Resolution**: Updated `bin/polyterm` and `common/palette.sh` to check if a user-controlled active repository directory exists (at `$DOTFILES_ROOT` or fallback `~/dotfiles`) with a valid `/common/palette` library folder, prioritizing it as `REPO_PATH` over the Homebrew cellar prefix folder.

## [ISSUE-19] ✅ Palette Menu Is Not Working
- **Status**: Resolved
- **Description**: The Command Palette menu is not working.
- **Resolution**: Removed a non-functional global scope `local` declaration of `device_id` in `common/palette/palette.sh`. Appended missing continuation backslashes (`\`) on the multi-line `fzf` invocations in `common/palette/docs.sh` and `common/palette/shortcuts.sh`.

## [ISSUE-20] ✅ Syntax/Runtime Errors in Zsh Profiles due to C-style Comments
- **Status**: Resolved
- **Description**: Sourcing `OS/linux/zshrc` and `OS/mac/.zshrc` produces startup errors because of C-style comment syntax `// 🖥️ ...` on line 3. This leads to `unknown file attribute: C` on Linux and `permission denied: //` on macOS.
- **Resolution**: Replaced the C-style `//` comments with shell-style `#` comment markers in both profiles.

## [ISSUE-21] ✅ Top-Level local Declarations Crash in Bootstrap Installer
- **Status**: Resolved
- **Description**: The bootstrap script `application-package/install.sh` contains several `local` keyword variables at the top-level script scope (outside any function). Executing the installer triggers a fatal error `local: can only be used in a function` and terminates immediately.
- **Resolution**: Removed the `local` keyword from all top-level script variable definitions in `install.sh`.

## [ISSUE-22] ✅ Hardcoded DOTFILES_ROOT Path in macOS Zsh Profiles
- **Status**: Resolved
- **Description**: `OS/mac/zshrc` hardcodes `DOTFILES_ROOT` to `~/GitHub/mmmonowar/dotfiles`, whereas the installer clones the repository to `~/dotfiles` by default. This causes absolute path lookup failures for command palette assets and scripts on macOS if cloned to standard paths.
- **Resolution**: Resolved `DOTFILES_ROOT` dynamically in the macOS shell profile `OS/mac/zshrc` using Zsh dynamic path lookup syntax, matching the Linux and WSL profiles.

## [ISSUE-23] ✅ Interactive Multiplexer Autostart Blocks Non-Interactive Command Execution
- **Status**: Resolved
- **Description**: Commands invoked by `polyterm` CLI (like `polyterm sync`) spawned Zsh interactively with `zsh -ic`. When run from a normal terminal outside Tmux, this triggered the zshrc auto-start multiplexer script, opening Tmux or Zellij and blocking the command execution until the user manually exits the multiplexer.
- **Resolution**:
    - Set `POLYTERM_CLI=1` environment variable before each `zsh -ic` invocation in `bin/polyterm` (for scan, sync, pull, reload commands).
    - Added a guard `[[ -n "$POLYTERM_CLI" ]] && unset POLYTERM_CLI && return` before the auto-start multiplexer block in all three Zsh profiles: `OS/linux/zshrc`, `OS/mac/.zshrc`, and `OS/wsl/zshrc`.
    - The sentinel approach is explicit, portable across Zsh versions, and directly tied to the `polyterm` binary's invocation context.

## [ISSUE-24] ✅ Hardcoded Paths and Redundancy in Active User Settings
- **Status**: Resolved
- **Description**: The active settings file `common/config/polyterm/.polyterm_settings` contained hardcoded paths (`/home/mustafa` and `/Users/mustafa.fl`) instead of portable `$HOME` references, violating the portability standard set in Issue 3. Additionally, a redundant, duplicate copy `common/polyterm_settings` existed at the root of `common/` causing confusion.
- **Resolution**:
    - Replaced hardcoded `/home/mustafa` and `/Users/mustafa.fl` paths with `$HOME` in `common/config/polyterm/.polyterm_settings`.
    - Removed the redundant duplicate file `common/polyterm_settings`.
    - Updated `project-manager/system-manual.md` to reference the correct settings file path `common/config/polyterm/.polyterm_settings`.

## [ISSUE-25] ✅ Alt+p / `palette` Command Fails — BASH_SOURCE Empty When Sourced
- **Status**: Resolved
- **Description**: Pressing `Alt+p` or running the `palette` function (defined in `common/palette/sync.sh`) sources `palette.sh`. In a sourced context, `BASH_SOURCE[0]` is empty, so `dirname ""` resolved to `.` and `PALETTE_LIB` was set to `pwd` (the repo root) instead of `common/palette/`. All 5 `source` commands then looked for sub-scripts in the wrong directory.
- **Diagnosis**: Debug probe at `palette.sh:49` confirmed `BASH_SOURCE=` (empty), `PALETTE_LIB='/home/muhammad/GitHub/mmmonowar/dotfiles'` (wrong), and all 5 sub-scripts `MISSING` — because `"$( cd "$( dirname "" )" && pwd )"` returns the current working directory, not the script's directory.
- **Resolution**:
    - Replaced `PALETTE_LIB` computation from `BASH_SOURCE`-based: `"$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"`
    - To a direct path using the already-resolved `REPO_PATH`: `"${REPO_PATH}/common/palette"`
    - This works in both executed and sourced contexts since `REPO_PATH` is derived from `DOTFILES_ROOT` (which is always set by the shell profile).

## [TASK-01] ✅ Zellij Peppermint Theme — Stale Copy Overwriting Repo Version
- **Status**: Resolved
- **Description**: Zellij loading wrong peppermint theme colors. `~/.config/zellij/themes/peppermint.kdl` contained a stale Dracula-ish color scheme that differed from the canonical theme in `common/config/zellij/themes/peppermint.kdl`. Since Zellij loads themes from both `~/.config/zellij/themes/` (default) and `theme_dir` (repo), the stale copy took precedence.
- **Resolution**:
    - Removed stale `~/.config/zellij/themes/peppermint.kdl` — Zellij now loads the correct theme from `theme_dir` (pointing to the repo's `common/config/zellij/themes/`).
    - Also removed stray `~/.config/zellij/themes/zshrc` that was accidentally placed in the themes directory.

## [ISSUE-26] ✅ Command Palette Menu Items Truncated with "..."
- **Status**: Resolved
- **Description**: When opening the Command Palette (main menu or sub-menus), some menu items are visually truncated and display `...` at the end. This breaks the expected consistent presentation — users can't read the full description of items like "PolyOS-dev", "Device Manager", and especially scratchpad paths.
- **Diagnosis**:
    - Every `fzf` call in the palette (10 total across 5 files) uses `--with-nth 1,2,3`, which **concatenates** the index, icon+name, and description into a single display line.
    - `fzf` has no wrapping or per-column width limit — if the concatenated line exceeds terminal width, it **hard-truncates** with `...`.
    - Measured worst offenders (visual width, 2‑col Nerd Font glyphs included):
        - `"Manage PolyOS development repositories and tools"` = **~53 chars** — truncates at ≤72-col
        - `"Scan, manage, and SSH into connected devices"` = **~48 chars** — truncates at ≤72-col
        - `"Auto-detect system and update device registry"` = **~49 chars** — truncates at ≤72-col
        - Scratchpad path (fully resolved filesystem path) = **~98 chars** — truncates at all common widths
    - All 10 fzf invocations affected:
        | # | File:Line | Function | Worst description |
        |---|---|---|---|
        | 1 | menu.sh:158 | `main_menu` | 5 items ≥40 chars |
        | 2 | menu.sh:100 | `documents_menu` | long filenames |
        | 3 | menu.sh:131 | `polyos_dev_menu` | 52 chars |
        | 4 | apps.sh:79 | `uninstall_app` | N/A (no `--with-nth`) |
        | 5 | apps.sh:156 | `apps_menu` | brew descriptions |
        | 6 | shortcuts.sh:35 | `shortcuts_menu` | tmux commands in desc |
        | 7 | devices.sh:20 | `devices_menu` | 47 chars |
        | 8 | devices.sh:79 | `ssh_into_device` | device data (short) |
        | 9 | settings.sh:87 | `scratchpad_menu` | **full file paths** |
        | 10 | settings.sh:128 | `settings_menu` | short toggles |
    - ANSI escape codes (`\033[2m...\033[0m`, 9 B per pair) are correctly accounted for by fzf but add to the logical line width.
    - No fzf flag exists to set per-column max width, wrap text, or soft-truncate per field.
- **Resolution**:
    - Added `truncate_desc()` helper to `common/palette/helpers.sh:107` — strips ANSI codes for accurate length calculation, truncates to a configurable max (default 40 chars), and preserves dim styling on truncated output.
    - Shortened 6 hardcoded descriptions in `common/palette/menu.sh` (`list_all_items`) to ≤40 chars:
        - `"Read all documentation in project-manager/"` → `"Read docs in project-manager/"`
        - `"Manage PolyOS development repositories and tools"` → `"Manage PolyOS dev repos & tools"`
        - `"Sync local configs to GitHub (Self-Healing)"` → `"Sync configs to GitHub"`
        - `"Run audit and package vulnerability checks"` → `"Run audit & vulnerability checks"`
        - `"Scan, manage, and SSH into connected devices"` → `"Scan, manage, SSH into devices"`
        - `"Clone or update all PolyOS repositories from GitHub"` → `"Clone or update PolyOS repos from GitHub"`
    - Shortened 1 description in `common/palette/devices.sh:12` (`devices_menu`):
        - `"Auto-detect system and update device registry"` → `"Auto-detect and update device info"`
    - Applied `truncate_desc` to dynamic scratchpad path variables in `common/palette/settings.sh:83-85` (`scratchpad_menu`) — paths like `$POLYTERM_SCRATCHPAD_LINUX` (which can be 60+ chars) are now clipped to 40 chars in the menu display while the full path is preserved for file operations.
    - All items now fit within ≤80‑col terminals and most fit within ≤72‑col terminals.

## [ISSUE-27] ✅ `dot-reload` Command Fails — `confirm_action` Not Found
- **Status**: Resolved
- **Description**: Running `dot-reload` from the shell prompt or via `polyterm reload` triggers `dot-reload-all`, which calls `confirm_action` on its 10th line. This fails with `dot-reload-all:10: command not found: confirm_action`. The `dot-reload` command is defined in `common/palette/sync.sh` (sourced from the OS-specific zshrc), but `confirm_action` is defined in `common/palette/helpers.sh` — which is only sourced from `common/palette/palette.sh` (the Command Palette entry point). When `dot-reload-all` is invoked outside the palette context (e.g., directly from the shell or via `bin/polyterm reload` which spawns a new `zsh -ic`), `helpers.sh` is never sourced, so `confirm_action` is undefined.
- **Resolution**: Sourced `common/palette/helpers.sh` in each OS-specific zshrc (`OS/linux/zshrc`, `OS/mac/.zshrc`, `OS/wsl/zshrc`) before sourcing `sync.sh`, ensuring `confirm_action` is available in all interactive shell contexts where `sync.sh` functions are called.

## [ISSUE-28] ✅ Interactive Reload Menu Item Broken — Popup Pane Targeting
- **Status**: Resolved
- **Description**: The "Reload Configs" menu item (and all other `trigger_zsh_func` actions — pull, push, poly-sync, scan) did not work when invoked from the Command Palette via `tmux display-popup`. The palette captures the target pane using `#{pane_id}`, which returns the popup's own pane ID instead of the underlying shell pane. When `trigger_zsh_func` sends keystrokes to `$TARGET_PANE`, they arrive in the closing popup rather than the user's shell, so the target function never executes.
- **Diagnosis**:
    - `common/palette/palette.sh:9`: `TARGET_PANE=$(tmux display-message -p '#{pane_id}')` captures popup's own pane.
    - `common/palette/helpers.sh:57`: `tmux send-keys -t "$TARGET_PANE"` sends to wrong pane.
    - All 5 `trigger_zsh_func` call sites affected: pull, push, poly-sync, reload, scan.
    - `OS/mac/zshrc:88`: `alias dot-reload` shadowed the `dot-reload()` function from `sync.sh`, and `mac/zshrc` was missing sourcing of `helpers.sh`/`sync.sh`.
    - `common/palette/sync.sh:129`: `dot-reload()` sourced `~/.zshrc`, causing recursive redefinition of functions via `sync.sh`.
    - `common/config/tmux/tmux.conf:83`: `Alt+r` binding ran `source ~/.zshrc && dot-reload`, double-sourcing shell configs.
- **Resolution**:
    - Changed `#{pane_id}` to `#{client_pane_id}` in `palette.sh:9` — `client_pane_id` returns the pane the client is focused on (the one behind the popup), fixing all `trigger_zsh_func` actions at once.
    - Added `helpers.sh` and `sync.sh` sourcing to `OS/mac/zshrc` to match the sourcing pattern in all other zshrc files, and removed the conflicting `alias dot-reload`.
    - Restructured `dot-reload()` in `sync.sh` to explicitly re-source `sync.sh` after sourcing `~/.zshrc`, preventing stale function definitions.
     - Simplified `Alt+r` binding in `tmux.conf:83` to send only `dot-reload`, removing the redundant `source ~/.zshrc &&` prefix.

## [ISSUE-29] ✅ Command Palette Launch Apps — Binary Name Mismatch (superfile → spf)
- **Status**: Resolved
- **Description**: When selecting apps from the Command Palette's Launch App menu (`apps_menu`), some CLI tools fail to launch. For example, `superfile` produces `command not found` instead of opening the file manager. Not all brew package names match their installed binary name.
- **Diagnosis**:
    - `common/palette/apps.sh:185` sends the brew package name directly to the shell via `trigger_zsh_func "$selected_app"`.
    - For `superfile`, the brew formula installs the binary as `spf`, not `superfile`:
      - `which superfile` → not found
      - `which spf` → `/home/linuxbrew/.linuxbrew/bin/spf`
    - Other brew packages may have similar mismatches (e.g., `gemini-cli` vs `gemini`).
    - The cask-on-Linux launch path (`trigger_zsh_func "$selected_app &"`) has the same vulnerability.
- **Resolution**:
    - Added `resolve_command()` to `common/palette/helpers.sh:131` — fast-paths via `command -v "$pkg_name"`, and falls back to inspecting the brew cellar `bin/` directory (via `brew --cellar`) to discover the actual binary name when the package name isn't a valid command. Returns the original name as a graceful fallback.
    - Updated `common/palette/apps.sh:178-189` to call `resolve_command("$selected_app")` before launching, using the resolved name for both CLI tool and cask-on-Linux launch paths.
    - Verified: `superfile` → `spf`, `lazygit` → `lazygit` (pass-through), `btop` → `btop` (pass-through).

## [ISSUE-31] ✅ Zellij Config Manager: Selecting Setting Returns "Unknown setting type" Error
- **Status**: Resolved
- **Description**: When selecting any setting from the Zellij Configuration Manager menu, the palette displayed `Unknown setting type '' for '<key>'` and returned to the config manager menu without saving.
- **Diagnosis**:
  - The `zellij_config_menu` in `common/palette/config_manager.sh` parsed the user's fzf selection using `cut -d '|' -f 4` and `cut -d '|' -f 5` to extract the type and argument.
  - The fzf output line for a setting looks like: `1 | 󰇒  mouse_mode true | ... | SETTING | mouse_mode|bool|Disable if...|true,false`
  - The metadata in column 5 (`mouse_mode|bool|hint|true,false`) contains its own `|` separators.
  - `cut -d '|' -f 5` split on **every** `|`, so it returned only `mouse_mode` instead of the full metadata string.
  - When the code then parsed this truncated string for `setting_type` via `cut -d '|' -f 2`, it got an empty string, which didn't match `bool`, `choice`, or `string`, and fell into the `*)` error case.
- **Resolution**:
  - Replaced `cut -d '|'` with `awk -F' \\| '` (using the same space-pipe-space delimiter as fzf's `--delimiter`) in `config_manager.sh:121-122` so that column 5 is extracted as a single field including its internal `|` characters.
  - No other call sites affected because their arguments don't contain internal `|`.

## [ISSUE-30] ✅ Zellij Alt+Left/Right Not Cycling Through Panes
- **Status**: Resolved
- **Description**: `Alt+Left` and `Alt+Right` in Zellij navigated by compass direction (`MoveFocus "left"` / `MoveFocus "right"`), so they did nothing when no pane existed physically to the left/right. Expected behavior is cycling through all panes in index order (like tmux `select-pane -t :.+`/`:.-`).
- **Diagnosis**:
    - `common/config/zellij/config.kdl` in `shared_among "normal" "locked"` bound `Alt left` to `MoveFocus "left"` and `Alt right` to `MoveFocus "right"` — directional, not cyclic.
    - Zellij provides `FocusNextPane` and `FocusPreviousPane` actions that cycle through panes in order (documented in Zellij CLI actions as `focus-next-pane`/`focus-previous-pane`).
    - Same directional bindings existed in `scroll` mode (using `MoveFocusOrTab`, which wraps to tabs but doesn't cycle panes).
- **Resolution**:
    - Replaced `MoveFocus "left"` with `FocusPreviousPane` for `Alt left` in both `shared_among "normal" "locked"` and `scroll` mode.
    - Replaced `MoveFocus "right"` with `FocusNextPane` for `Alt right` in both `shared_among "normal" "locked"` and `scroll` mode.
    - `Alt+Left` now cycles to the previous pane (backwards), `Alt+Right` cycles to the next pane (forward), matching tmux behavior.


