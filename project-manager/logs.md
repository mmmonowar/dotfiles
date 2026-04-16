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

## [2026-04-17] ✨ Dynamic App Descriptions in Palette
- **Feature**: Command Palette now shows descriptions for CLI tools.
- **Changes**:
  - Enhanced `get_app_description` in `common/palette.sh` to fetch descriptions using `brew info`.
  - Implemented caching to `apps_meta.txt` to ensure fast loading in subsequent uses.
  - Added "Loading..." indicator to `apps_menu` while fetching metadata.
  - Added automatic cleanup of metadata upon uninstallation.
  - Updated documentation (`features.md`, `tasks.md`, `plan.md`).
- **Impact**: Improved user experience when browsing and launching tools from the palette.
