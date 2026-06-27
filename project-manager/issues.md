## ✅ Path Confusion & Naming Inconsistency
- **Status**: Resolved
- **Description**: Inconsistent naming (hidden `.zshrc` in repo vs visible `zshrc`) and hardcoded installer paths caused duplicate repository clones and user confusion.
- **Resolution**:
    - Unified all repository configuration sources to be visible files (e.g., `mac/zshrc`, `common/polyterm_settings`).
    - Enhanced `application-package/install.sh` to automatically detect if it is running from within an existing repository.
    - Standardized the bootstrap process to respect the current repository location, preventing duplicate clones to `~/dotfiles`.
    - Updated all internal references in Zsh profiles and the Command Palette to the new visible filenames.

## ✅ Micro PolyMark Theme Missing (Linux)
- **Status**: Resolved
- **Description**: The PolyMark colorscheme was present in the repository but not activated by default in the Micro editor, leading to it appearing "missing" on Linux.
- **Resolution**: Updated `common/micro/settings.json` to explicitly set `colorscheme: PolyMark` and enable `truecolor: "auto"` for consistent cross-platform activation.

## ✅ Homebrew Permission Denied & Multi-User Portability (Linux)
- **Status**: Resolved
- **Description**: `brew install` failed with `Permission denied` because a security scan script incorrectly chowned the Homebrew root to `root:root`. Additionally, hardcoded user paths in settings broke portability for different developers.
- **Resolution**: 
    - Restored Homebrew ownership to the current user.
    - Updated `common/security.sh` with adaptive "self-healing" that ensures the *active* user owns Homebrew, instead of forcing it to root.
    - Converted all hardcoded paths in `common/.polyterm_settings` to use the `$HOME` environment variable.
    - Enhanced the Command Palette's `update_setting` function to automatically preserve `$HOME` when saving paths, ensuring the configuration remains portable across all devices and users.

## ✅ Tmux Initialization Errors
- **Status**: Resolved
- **Description**: Terminal displays "can't find session: default" and "open terminal failed: not a terminal" upon startup.
- **Resolution**: Added interactivity check `[[ -o interactive ]]` and suppressed stderr for the initial attach attempt in `.zshrc`.

## ✅ Slow Homebrew Installations (Cleanup)
- **Status**: Resolved
- **Description**: `brew install` triggers an automatic cleanup process that takes a significant amount of time.
- **Resolution**: Set `HOMEBREW_NO_INSTALL_CLEANUP=1` in `.zshrc` to disable automatic cleanup after every installation.

## ✅ Alt Key Compatibility (macOS & Ubuntu)
- **Status**: Resolved
- **Description**: Alt/Option shortcuts (like Alt+p) were not registered by Tmux.
- **Resolution**: 
    - Implemented `common/fix-alt-keys.sh` which automates the disabling of GNOME Terminal menu accelerators on Ubuntu.
    - Provided clear in-terminal instructions for configuring macOS Terminal.app and iTerm2 to use "Option as Meta".
    - Added a "Fix Alt Keys" entry to the Command Palette for instant troubleshooting.

