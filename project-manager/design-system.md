# Peppermint Design System

> [!NOTE]
> Registered: 2026-06-21-02-25-00
> Status: Active

## Design Tokens
The Peppermint design language is designed for premium, high-contrast, immersive cockpit views.

| Token | Hex Value | Usage |
| --- | --- | --- |
| Pure Black | `#000000` | Terminal background, status bar base |
| Peppermint Teal | `#14b8a6` | Active highlights, focus markers, indicators |
| Bright Black | `#2a2a2a` | Pane borders, delimiters |
| Soft White | `#b4b4b4` | Inactive window markers, labels |

## Style Synchronizer
Themes for Tmux, Zellij, Micro editor, and FZF are hardcoded to these values.
- **Tmux**: `common/config/tmux/tmux.conf`
- **Zellij**: `common/config/zellij/config.kdl`
- **Micro**: `common/config/micro/colorschemes/PolyMark.micro`
- **FZF**: `common/palette/palette.sh`
