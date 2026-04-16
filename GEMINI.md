# Gemini Instructions - Dotfiles Repository

This file contains repository-specific instructions and context for Gemini CLI.

## Repository Structure
- `common/`: Shared configurations (Tmux, Micro editor, Palette script).
- `mac/`: macOS-specific configurations (Zshrc, Brewfile).
- `wsl/`: WSL/Ubuntu-specific configurations (Zshrc, Brewfile).
- `project-manager/`: Documentation, tasks, and plans.

## Key Automation Commands
- `dot-sync`: Automatically dumps the current Brewfile, stages all changes, commits with a timestamp, and pushes to GitHub.
- `dot-pull`: Pulls latest changes from GitHub, installs any new dependencies from the Brewfile, and reloads the shell.

## Command Palette (`common/palette.sh`)
- Triggered via `Alt+p` in Tmux.
- When installing or uninstalling apps via the palette, `dot-sync` is automatically triggered to keep the repository in sync.

## Documentation & Process Standards
- **Feature Implementation**: Whenever a new feature is implemented, you MUST update `project-manager/plan.md`, `project-manager/features.md`, `project-manager/tasks.md`, and `project-manager/issues.md` (if relevant) to reflect current progress and state.
- **Change Logs**: Maintain a timestamped, human-readable record of all significant updates in `project-manager/logs.md`.
- **Cross-Platform Compatibility**: Always ensure changes work across both macOS and WSL environments.
- **Messaging**: Use clear, emoji-supported human-readable messages in all automation scripts and logs.

