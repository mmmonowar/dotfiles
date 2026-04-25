# 🎨 PolyTerm Design System

## Peppermint Theme (Foundational)
... (existing content) ...

---

## Sublime Focus (Tmux Specialization)

The **Sublime Focus** aesthetic is designed to mimic the immersive, "infinite canvas" feel of the Sublime Text editor.

### Color Palette

| Name | Hex | Usage |
| :--- | :--- | :--- |
| **Pure Black** | `#000000` | Background for ALL panes |
| **Vibrant Teal** | `#14b8a6` | Active pane border |
| **Dark Grey** | `#2a2a2a` | Inactive pane border |

### Design Principles

1.  **Immersive Canvas**: By using a uniform `#000000` background across all panes, the terminal interface recedes, allowing the code and content to take center stage.
2.  **High-Visibility Focus**: A vibrant teal border provides an unmistakable indicator of the active pane without the need for text labels.
3.  **Minimalist Interface**: Disabling border status labels (`pane-border-status off`) ensures a clean, distraction-free environment.
4.  **Simulated Padding**: While tmux lacks native internal padding, the uniform black background minimizes the "harshness" of borders touching text.

---

## Tmux Implementation

- **Active Pane**: Background `#000000`, Border `#14b8a6`
- **Inactive Pane**: Background `#000000`, Border `#2a2a2a`
- **Status Bar**: Peppermint Blue (`#449fd0`) on Black (`#000000`) for clear system feedback.
