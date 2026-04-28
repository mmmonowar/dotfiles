# 🎨 PolyTerm Design System

## Peppermint Theme (Foundational)

The Peppermint theme is the core color palette for PolyTerm, providing a balanced, high-contrast environment for coding and terminal use.

### Color Palette

| Name | Hex | Usage |
| :--- | :--- | :--- |
| **Background** | `#000000` | Global background for all apps |
| **Foreground** | `#c8c8c8` | Default text color |
| **Black** | `#353535` | Subdued elements |
| **Red** | `#e74669` | Alerts, errors, deletions |
| **Green** | `#89d287` | Success, additions, tasks |
| **Yellow** | `#dab853` | Warnings, headers, incomplete tasks |
| **Blue** | `#449fd0` | Primary accent, status indicators |
| **Purple** | `#da62dc` | Metadata, tags |
| **Cyan (Teal)** | `#14b8a6` | Focus highlights, active elements |
| **White** | `#b4b4b4` | Secondary text |
| **Bright Black** | `#2a2a2a` | Inactive borders, selection background |

## Design Principles

1.  **Immersive Canvas**: By using a uniform `#000000` background across all panes and popups, the terminal interface recedes, allowing the code and content to take center stage.
2.  **Teal-Centric Highlighting**: Peppermint Cyan/Teal (`#14b8a6`) is the primary "focus" color for borders, prompts, and selections, providing a modern, greenish aesthetic.
3.  **Green for Affirmation**: Peppermint Green (`#89d287`) is used for success states and secondary informational markers.
4.  **Minimalist Interface**: Disabling border status labels and using rounded, high-contrast borders ensure a clean, distraction-free environment.

---

## Tmux Implementation

- **Active Pane**: Background `#000000`, Rounded Border `#14b8a6` (Peppermint Teal)
- **Inactive Pane**: Background `#000000`, Border `#2a2a2a` (Peppermint Bright Black)
- **Status Bar**: 
    - **Position**: Bottom, strictly aligned to the "Sublime Focus" aesthetic.
    - **Colors**: Peppermint Teal (`#14b8a6`) foreground on Pure Black (`#000000`) background.
    - **Session Indicator**: High-fidelity Nerd Font glyph (`󱓞`) with high-contrast Teal background.
    - **Window Status**: Modern "Powerline" styling using arrows (``, ``) and focal icons (`󱐋`).
- **Command Palette (Popup)**: Background `#000000`, Rounded Border `#14b8a6`.
- **UI Elements**: Message line and selection highlights use Peppermint Teal for high visibility.

---

## Application Integration

### Micro Editor
Micro uses the `PolyMark.micro` colorscheme, which maps the Peppermint palette to editor tokens.
- **Headings/Questions**: Peppermint Blue (`#449fd0`)
- **Focus/Markers**: Peppermint Cyan (`#14b8a6`)
- **Strings/Success**: Peppermint Green (`#89d287`)

### Glow (Markdown)
Glow inherits terminal colors, ensuring it matches the Peppermint background and accents.

### Command Palette (fzf)
The palette uses `fzf` themed with the Peppermint palette:
- **Selection Highlight**: Peppermint Teal (`#14b8a6`)
- **Selection Background**: Peppermint Bright Black (`#2a2a2a`)
- **Success Markers**: Peppermint Green (`#89d287`)
