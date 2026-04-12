# Project Issues

## 🛑 Monochrome Micro (No Colors)
- **Status**: Open
- **Description**: After applying the `PolyMark` colorscheme, Micro only displays black and white text, even when running inside Tmux.
- **Potential Causes**:
    - [x] Terminal/Tmux `COLORTERM` or `TERM` mismatch.
    - [ ] Micro fails to parse hex codes if truecolor is not fully negotiated.
    - [ ] `color-link default` setting might be causing a global override to black/white.
    - [ ] Syntax file (`PolyMark.yaml`) rules not triggering, leading to no scopes being colored.
- **Resolution Plan**:
    - [x] Update `tmux.conf` to include `set -ga terminal-overrides ",xterm-256color:Tc"`.
    - [x] Add `export COLORTERM=truecolor` and `export MICRO_TRUECOLOR=1` to `.zshrc`.
    - [x] Set `truecolor` to `on` in Micro's `settings.json`.

