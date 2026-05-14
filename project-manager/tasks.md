# Project Tasks

## ✅ Cross-Platform Compatibility
- [x] Create directory structure for `mac/` and `wsl/`
- [x] Implement dynamic OS detection in `palette.sh`
- [x] Define OS-specific Brewfile and metadata paths

## ✅ Unified Command Palette
- [x] Create `palette.sh` with `fzf` integration
- [x] Implement unified search discovery (flattened menu items) in main palette
- [x] Implement application launching from Brewfile
- [x] Implement dynamic documentation browser (Project Documents) for `project-manager/`
- [x] Implement dynamic app descriptions (blurbs) via `brew info`
- [x] Implement Executable Shortcut menu
- [x] Integrate Nerd Font glyphs for consistent UI
- [x] Implement confirmation prompts for destructive actions
- [x] Implement interactive install/uninstall functions
- [x] Implement persistent "Settings" menu for UX preferences (Security toggles)
- [x] Implement dedicated Scratchpad Settings menu for cross-platform path management
- [x] Implement PolyOS-dev sub-menu and `poly-sync` integration in the Command Palette
- [x] Bind `Alt+p` to trigger palette popup in `tmux.conf`

## ✅ Advanced Tmux Configuration
- [x] Implement session management (Alt+, , Alt+0, Alt+w)
- [x] Implement 2x2 grid management (Alt+1, Alt+2)
- [x] Configure Smart Dashboard (btop/docker) auto-start
- [x] Set up cross-platform clipboard (pbcopy/xclip)
- [x] Integrate Catppuccin theme and custom status bar
- [x] Implement centralized Peppermint Design System (`DESIGN.md` and `common/design/`)
- [x] Apply Sublime Focus aesthetic to Tmux (pure black bg, teal active borders, no labels)

## ✅ Declarative Package Management
- [x] Define `mac/Brewfile` with core CLI tools and VSCode extensions
- [x] Define `wsl/Brewfile` with Ubuntu-specific packages

## ✅ Shell Automation (Zsh)
- [x] Implement automated Zsh and Tmux startup via `.bashrc`
- [x] Create `dot-sync` and `dot-pull` for Git automation
- [x] Implement automated `hledger` journal synchronization and symbolic linking in `dot-sync`
- [x] Implement self-healing logic in `dot-sync` to automatically install missing dependencies
- [x] Implement `poly-sync` alias to clone/update all PolyOS repositories from GitHub
- [x] Implement automatic background Gemini CLI updates on shell startup
- [x] Implement Smart Brewfile Sync (auto-dump/auto-install)
- [x] Set any installation via dotfiles to be verbose
- [x] Optimize Homebrew performance (disable auto-cleanup)
- [x] Implement `search` alias via `ddgr`
- [x] Set up SSH agent auto-initialization for WSL
- [x] Implement integrated `dot-reload` for Zsh and Tmux
- [x] Implement conditional AI aliases for Gemini CLI (flash-lite, flash-3.0, pro-3.1) with 1h session timeout and billing monitoring
- [x] Implement support for local-only, machine-specific Zsh overrides (`~/.zshrc_local`)
- [x] Implement Gemini CLI safety wrapper (`ask_gemini`) for large file filtering
- [x] Implement cross-platform synchronization for Gemini CLI settings.
- [x] Implement 'Kill Gemini' menu item in command palette to terminate processes across sessions.

## ✅ Micro Editor Customization
- [x] Define `PolyMark.yaml` syntax rules
- [x] Create `PolyMark.micro` colorscheme
- [x] Link `common/micro/` configurations to `~/.config/micro/`
- [x] Implement GUI-style text selection (Shift+Arrows) and copy (Ctrl+C) for Micro and Tmux

## ✅ PolyMark Translation
- [x] Parse `polymark.sublime-syntax` contexts and matches
- [x] Map Sublime scopes to Micro `color-link` identifiers
- [x] Extract colors from `polymark.sublime-color-scheme`
- [x] Generate updated `common/micro/syntax/PolyMark.yaml`
- [x] Generate updated `common/micro/colorschemes/PolyMark.micro`

## ✅ Repository Portability
- [x] Dynamically determine repository root in `palette.sh`
- [x] Implement dynamic `DOTFILES_ROOT` detection in Zsh profiles
- [x] Synchronize `DOTFILES_ROOT` environment variable with Tmux
- [x] Convert all hardcoded absolute paths to relative or environment-based paths

## 🛠️ Troubleshooting
- [x] Fix Tmux "not a terminal" startup error
- [x] Diagnose monochrome display issue in Micro
- [x] Verify TrueColor support in Tmux/Terminal
- [x] Validate Micro colorscheme hex code compatibility and activation
- [x] Implement Alt/Option key compatibility for macOS and Ubuntu
- [x] Unify all Tmux shortcuts on the Alt (Meta) key across all platforms
- [x] Standardize `OS_ENV` across all platforms to fix Brewfile path resolution in `dot-pull` and `dot-sync`
- [x] Fix `mac/.zshrc` and `linux/zshrc` corruption to resolve Tmux configuration execution errors
- [x] Resolve Homebrew `Permission denied` errors by automating ownership fixes for `/home/linuxbrew/.linuxbrew`

## ✅ Security & Vulnerability Management
- [x] Create `common/security.sh` with `dot-scan` function
- [x] Integrate `shellcheck` for shell script static analysis and resolve all identified warnings
- [x] Implement automated package vulnerability checks via `brew outdated`
- [x] Integrate Homebrew health auditing (`brew doctor`)
- [x] Implement heuristic secret scanning for the repository with false positive reduction for system variables
- [x] Integrate `lynis` for system security auditing with automatic installation if missing
- [x] Embed automated security scans into `install.sh`, `dot-pull`, and `dot-sync`
- [x] Add security tools (`shellcheck`, `lynis`) to `Brewfile.core` across all platforms

## 🚀 Deployment & Installation
- [x] Implement unified application package installer (`install.sh`)
- [x] Add generic Linux support with `linux/zshrc`
- [x] Enable remote one-command installation via curl
- [x] Create `bin/polyterm` CLI tool
- [x] Implement Homebrew Formula (`Formula/polyterm.rb`) for Tap support
- [ ] Implement automated health checks for symbolic links
