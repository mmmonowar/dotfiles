# Project Logs

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
