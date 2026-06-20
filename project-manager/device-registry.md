# Device Registry Management

> [!NOTE]
> Registered: 2026-06-21-02-25-00
> Status: Active

## Overview
A dynamic device registry captures configuration details for all machines running PolyTerm dotfiles, organizing files by OS and Device parameters.

## Storage File
- **Path**: `data/device-list.yml`
- **Fields Captured**:
  - `id`: Unique identifier (hostname-based)
  - `username`: Operating user
  - `device-name`: Hostname
  - `device-model`: Hardware version
  - `operating-system`: OS environment
  - `operating-system-version`: OS version
  - `ip-address`: Local primary IP
  - `last-sync`: Timestamp of last sync (`YYYY-MM-DD-hh-mm-ss`)

## Integration
The registry is updated dynamically during every `dot-sync` via `common/palette/update_device.py`.
