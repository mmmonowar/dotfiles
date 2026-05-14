# Project Issues

## ✅ Tmux Sourcing & Selection Issues
- **Status**: Resolved
- **Description**: Sourcing `.tmux.conf` resulted in syntax errors (early expansion of `$(...)`) and `Shift+Arrow` selection/`Ctrl+c` copy didn't always take effect.
- **Resolution**: Fixed `M-1` binding by using single quotes to delay shell expansion. Refined `is_editor` detection for better macOS compatibility. Added explicit `copy-mode-vi` bindings for `Shift+Arrows` to ensure seamless selection.

## ✅ Micro PolyMark Theme Missing (Linux)
- **Status**: Resolved
- **Description**: The PolyMark colorscheme was present in the repository but not activated by default in the Micro editor, leading to it appearing "missing" on Linux.
- **Resolution**: Updated `common/micro/settings.json` to explicitly set `colorscheme: PolyMark` and enable `truecolor: "auto"` for consistent cross-platform activation.

## ✅ Homebrew Permission Denied (Linux)
- **Status**: Resolved
- **Description**: `brew install` fails with `Permission denied` when trying to rename files in `/home/linuxbrew/.linuxbrew/Cellar` or temp directories.
- **Resolution**: Changed ownership of `/home/linuxbrew/.linuxbrew` and all its subdirectories to the current user (`mustafa`) using `sudo chown -R $(whoami) /home/linuxbrew/.linuxbrew`.

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

## ✅ Cargo Shared Library Error (libllhttp)
- **Status**: Resolved
- **Description**: `cargo` failed with `libllhttp.so.9.3: cannot open shared object file` after a background Homebrew update.
- **Resolution**: Upgraded and reinstalled `libgit2` (which depends on `llhttp`) and `rust`. This correctly linked the binaries to the newer `llhttp` version (9.4.1) and resolved the dependency mismatch.

