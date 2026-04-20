# Project Tasks

## ✅ Cross-Platform Compatibility
- [x] Create directory structure for `mac/` and `wsl/`
- [x] Implement dynamic OS detection in `palette.sh`
- [x] Define OS-specific Brewfile and metadata paths

## ✅ Unified Command Palette
- [x] Create `palette.sh` with `fzf` integration
- [x] Implement application launching from Brewfile
- [x] Implement dynamic app descriptions (blurbs) via `brew info`
- [x] Implement Executable Shortcut menu
- [x] Integrate Nerd Font glyphs for consistent UI
- [x] Implement confirmation prompts for destructive actions
- [x] Implement interactive install/uninstall functions
- [x] Bind `Alt+p` to trigger palette popup in `tmux.conf`

## ✅ Advanced Tmux Configuration
- [x] Implement session management (Alt+, , Alt+0, Alt+w)
- [x] Implement 2x2 grid management (Alt+1, Alt+2)
- [x] Configure Smart Dashboard (btop/docker) auto-start
- [x] Set up cross-platform clipboard (pbcopy/xclip)
- [x] Integrate Catppuccin theme and custom status bar

## ✅ Declarative Package Management
- [x] Define `mac/Brewfile` with core CLI tools and VSCode extensions
- [x] Define `wsl/Brewfile` with Ubuntu-specific packages

## ✅ Shell Automation (Zsh)
- [x] Implement automated Zsh and Tmux startup via `.bashrc`
- [x] Create `dot-sync` and `dot-pull` for Git automation
- [x] Implement Smart Brewfile Sync (auto-dump/auto-install)
- [x] Set any installation via dotfiles to be verbose
- [x] Optimize Homebrew performance (disable auto-cleanup)
- [x] Implement `search` alias via `ddgr`
- [x] Set up SSH agent auto-initialization for WSL
- [x] Implement integrated `dot-reload` for Zsh and Tmux

## ✅ Micro Editor Customization
- [x] Define `PolyMark.yaml` syntax rules
- [x] Create `PolyMark.micro` colorscheme
- [x] Link `common/micro/` configurations to `~/.config/micro/`

## ✅ PolyMark Translation
- [x] Parse `polymark.sublime-syntax` contexts and matches
- [x] Map Sublime scopes to Micro `color-link` identifiers
- [x] Extract colors from `polymark.sublime-color-scheme`
- [x] Generate updated `common/micro/syntax/PolyMark.yaml`
- [x] Generate updated `common/micro/colorschemes/PolyMark.micro`

## 🛠️ Troubleshooting
- [x] Diagnose monochrome display issue in Micro
- [x] Verify TrueColor support in Tmux/Terminal
- [x] Validate Micro colorscheme hex code compatibility
