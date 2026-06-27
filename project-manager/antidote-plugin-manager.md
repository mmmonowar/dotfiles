# Antidote Plugin Manager

> [!NOTE]
> Registered: 2026-06-21-02-25-00
> Status: Active

## Overview
Antidote is a minimalist, fast, compiled Zsh plugin manager that replaces heavy, synchronous runtime loading with statically compiled load scripts.

## File Mappings
- **Registry**: `common/config/zsh/plugins.txt`
- **Link Location**: `~/.zsh_plugins.txt`
- **Compiled Output**: `~/.zsh_plugins.zsh`

## Performance
By compiling plugins statically on modification, terminal startup latency is reduced by up to 150ms.
Plugins are updated automatically during sync activity.
