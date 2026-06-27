# Refactoring and Code Architecture

> [!TIP]
> Registered: 2026-06-21-02-25-00
> Status: Active

## Decoupling Strategy
Long shell configurations and scripts are broken down into small, modular units:
1. `common/config/`: Flat configuration folders organized by program name.
2. `common/palette/`: All executable scripts and command helper functions.
3. `OS/`: Operating System-specific configs mapped by directory.

## File Locality rules
- If config is OS-specific: `OS/<mac/linux/wsl>/<config>`
- If config is Device-specific: `OS/<mac/linux/wsl>/<device-identifier>/<config>`

## Sync Integration
The `install.sh` and `sync.sh` scripts check for device-specific files first, falling back to OS-specific defaults.
