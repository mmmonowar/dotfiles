# 🎨 PolyTerm Design System

## Peppermint Theme

The **Peppermint** theme is the foundational aesthetic for PolyTerm, providing high contrast and comfortable ergonomics for long coding sessions.

### Color Palette

| Name | Hex | Usage |
| :--- | :--- | :--- |
| **Background** | `#000000` | Active terminal background |
| **Foreground** | `#c8c8c8` | Primary text |
| **Black** | `#353535` | Inactive borders, Subtle UI elements |
| **Bright Black**| `#535353` | Comments, Secondary UI |
| **Blue** | `#449fd0` | Active borders, Primary highlights |
| **Green** | `#89d287` | Success states |
| **Red** | `#e74669` | Error states |
| **Purple** | `#da62dc` | Secondary highlights |

### Design Principles

1.  **Comfortable Contrast**: Active workspaces use a solid black (`#000000`) background to minimize eye strain and maximize foreground readability.
2.  **Visual Hierarchy**: Inactive panes are dimmed to `#1c1c1c` to provide a clear focus on the active task without creating jarring transitions.
3.  **Interface Distinction**: Borders and status elements use distinct colors (Peppermint Blue for active, Peppermint Black for inactive) to define boundaries without unnecessary visual clutter.
4.  **Cross-Platform Consistency**: All themes and configurations (Zsh, Tmux, Micro) must align with these hex codes to ensure a seamless experience across macOS, WSL, and Linux.

---

## Tmux Implementation

- **Active Pane**: Background `#000000`, Border `#449fd0`
- **Inactive Pane**: Background `#1c1c1c`, Border `#353535`
- **Status Bar**: Aligned with the Peppermint palette for a unified look.
