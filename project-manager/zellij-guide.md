# Zellij Integration Guide

> [!NOTE]
> Registered: 2026-06-21-02-25-00
> Status: Active

## Overview
Zellij has been integrated into PolyTerm side-by-side with Tmux as an alternative terminal multiplexer. The layout configurations and themes are synchronized to mirror Tmux visual aesthetics.

## Configuration Details
- **Path**: `common/config/zellij/config.kdl`
- **Aesthetic**: Pure black background (`#000000`), Peppermint Teal accents (`#14b8a6`), and no pane borders/frames (`pane_frames false`).
- **Keybindings**: Alt/Meta-based navigation matching Tmux exactly.

## Alt/Meta Mappings
- `Alt + Up/Down`: Cycle tabs (matches tmux windows)
- `Alt + Left/Right`: Focus pane
- `Alt + 1`: Split/New pane
- `Alt + 2`: Close focused pane
- `Alt + P`: Open command palette in floating window
