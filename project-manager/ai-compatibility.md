# AI Agent Compatibility Strategy

> [!IMPORTANT]
> Registered: 2026-06-21-02-25-00
> Status: Active

## Overview
To prevent custom terminal formatting, Nerd Font characters, complex aliases, or heavy plugins from slowing down or confusing agent parsers, a dynamic detection utility is implemented in all shell profiles.

## Detection Rules
The utility `is_agent_or_non_interactive` detects:
- Non-interactive shells (`[[ $- != *i* ]]`)
- Dumb terminals (`$TERM == "dumb"`)
- Non-TTY stdin/stdout (`[[ ! -t 1 ]]`)
- Common AI agent variables (`$ANTIGRAVITY` or `$AGENT_ENV`)

## Behavior Adjustments
If an agent or automated script is detected:
- Prompt fallback: simple clean `$ ` (no escape sequences)
- Skip Tmux/Zellij cockpit auto-start
- Skip Antidote plugin compilation and loading
- Bypass billing check / background startup processes
