# Project Issues

## ✅ Slow Homebrew Installations (Cleanup)
- **Status**: Resolved
- **Description**: `brew install` triggers an automatic cleanup process that takes a significant amount of time.
- **Resolution**: Set `HOMEBREW_NO_INSTALL_CLEANUP=1` in `.zshrc` to disable automatic cleanup after every installation.

## 🔄 Slow Brewfile Updates
- **Status**: Investigation
- **Description**: `brew bundle dump` takes a long time to list and categorize all installed packages.
- **Potential Causes**:
    - Querying all casks and formulae globally.
    - Network checks or metadata verification during the dump.
- **Resolution Plan**: Research if specific flags or environment variables can speed up the dumping process.

