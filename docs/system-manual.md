# 🛠️ PolyTerm System Manual

> [!NOTE]
> **Cross-Repo References**: This is a documentation-only companion to [mmmonowar/dotfiles](https://github.com/mmmonowar/dotfiles). File paths (e.g., `common/`, `OS/`, `bin/`) and URLs (e.g., `raw.githubusercontent.com/mmmonowar/dotfiles/...`) reference the parent `dotfiles` repo — not this one.

This document provides a technical overview of the PolyTerm architecture, file purposes, and system interdependencies for developers and administrators.

---

## 🏗️ System Architecture Overview

PolyTerm is designed as a modular, cross-platform terminal environment. It uses a "Core + OS-Layer" approach:
1.  **Core (`common/`)**: Shared logic and configurations used across all platforms.
2.  **OS-Layer (`linux/`, `mac/`, `wsl/`)**: Platform-specific entry points and package definitions.
3.  **CLI Interface (`bin/polyterm`)**: A wrapper that exposes system functions to the user.
4.  **Automation Layer**: Shell functions (`dot-sync`, `dot-pull`) in `common/palette/sync.sh` that handle Git and Homebrew synchronization with automatic rebase to prevent divergent branches.

### Key Environment Variables

| Variable | Set In | Purpose |
|----------|--------|---------|
| `DOTFILES_ROOT` | Each zshrc (line 9/16) | Root of the dotfiles repo (auto-resolved from zshrc symlink path) |
| `DOTFILES_DATA` | Each zshrc (line 10/17) + settings-loader.sh | Root of the mutable data repo (default: `$DOTFILES_ROOT/../polyterm-data`) |
| `OS_ENV` | Each zshrc | Current platform: `mac`, `wsl`, or `linux` |
| `POLYTERM_THEME` | `.polyterm_settings` | Active theme name |
| `POLYTERM_MULTIPLEXER` | `.polyterm_settings` | Auto-start multiplexer: `tmux`, `zellij`, or `none` |
| `POLYTERM_WELCOME` | `.polyterm_settings` | Welcome banner toggle: `on` (default) or `off` |

`DOTFILES_DATA` can be overridden via `~/.zshenv` (sourced before `.zshrc`):
```bash
export DOTFILES_DATA="/your/custom/path/to/polyterm-data"
```

---

## 📂 Directory & File Map

### 1. Root Directory
| Path | Purpose | Criticality | If Damaged/Deleted |
| :--- | :--- | :--- | :--- |
| `bin/polyterm` | Main entry point for the `polyterm` command. | **High** | The `polyterm` command will fail; manual environment management required. |
| `README.md` | General overview and installation instructions. | Low | Onboarding becomes difficult for new users. |

### 2. `common/` (Shared Configurations)
| Path | Purpose | Interdependencies | If Damaged/Deleted |
| :--- | :--- | :--- | :--- |
| `tmux.conf` | Shared Tmux settings and keybindings. | Referenced by `~/.tmux.conf` | Tmux loses its custom layout, shortcuts, and themes. |
| `palette.sh` | Main entry point for the Command Palette. | Sources `common/palette/*.sh` | The Command Palette will not open; interactive package management fails. |
| `palette/` | Modular subscripts for the Command Palette. | Loaded by `palette.sh` | Specific palette functions (Apps, Docs, Settings) will fail. |
| `security.sh` | Logic for `dot-scan` and security audits. | Called by `dot-sync` and `dot-pull` | Security checks and vulnerability scanning will fail. |
| `micro/` | Custom syntax and theme for Micro editor. | Symlinked to `~/.config/micro` | Micro editor reverts to default colors and loses PolyMark support. |

---

## 📂 Directory & File Map (Sub-Scripts)

### `common/palette/` (Modular Logic)
| Path | Purpose | Key Functionality |
| :--- | :--- | :--- |
| `helpers.sh` | Shared utilities | `update_setting`, `trigger_zsh_func`, `confirm_action`. |
| `apps.sh` | Package Management | `install_app`, `uninstall_app`, `apps_menu`. |
| `docs.sh` | Document Browser | `documents_menu` (scans `project-manager/`). |
| `settings.sh` | System Preferences | `settings_menu`, `scratchpad_menu`, `open_scratchpad`. |
| `shortcuts.sh` | Tmux Automation | `shortcuts_menu`, `execute_shortcut`. |
| `menu.sh` | Palette Core | `main_menu`, `list_all_items` (Global Search logic). |
| `welcome.sh` | Welcome Banner | `polyterm_welcome`, `polyterm_clear` (login banner display). |

### 3. OS-Specific Directories (`linux/`, `mac/`, `wsl/`)
| Path | Purpose | Interdependencies | If Damaged/Deleted |
| :--- | :--- | :--- | :--- |
| `zshrc` | Primary shell configuration for the platform. | Sources `common/` logic | Shell startup fails; aliases, functions, and `username@hostname` prompt lost. |
| `Brewfile.core` | Essential system packages (Git, Tmux, FZF). | Used by `dot-sync` (Healing) | Core tools cannot be automatically reinstalled or updated. |
| `Brewfile.apps` | User-installed CLI tools and apps. | Managed by Palette + `dot-sync` | Application list is lost; difficult to reproduce the environment. |
| `apps_meta.txt` | Cached descriptions for the App Launcher. | Used by `palette.sh` | Palette becomes slow as it fetches descriptions from Homebrew. |

---

## 🔄 Core Workflows & Logic

### 1. Self-Healing Sync (`dot-sync`)
-   **Location**: Defined in `common/palette/sync.sh`.
-   **Logic**: Before committing, it pulls remote changes with `--rebase` to prevent divergent branches across multi-device workflows. Falls back to merge if rebase fails. Before updating the `Brewfile`, it runs `brew bundle check`. If unsatisfied, it automatically runs `brew bundle` to install/update dependencies.
-   **Failure Impact**: If the healing logic is corrupted, users might push incomplete configurations or use an out-of-sync environment.

### 2. Integrated Reloading (`dot-reload`)
-   **Location**: Defined in `[os]/zshrc`.
-   **Logic**: Sources the local `.zshrc` and explicitly triggers `tmux source-file ~/.tmux.conf`.
-   **Improvement**: It now detects if a Tmux server is running and reloads the configuration even if the command is executed from a standard shell pane, ensuring consistent environment state.

### 3. Command Palette UI
-   **Location**: `common/palette.sh` (Entry) → `common/palette/*.sh` (Implementation).
-   **Logic**: Uses `fzf` with `--ansi`. Settings are persisted in `polyterm-data/settings/.polyterm_settings`.
-   **Failure Impact**: Corruption leads to UI rendering issues or script execution errors when selecting menu items.

### 4. Theme System Architecture
-   **Entry Point**: `common/palette/themes.sh` sourced by `palette.sh` and all OS zshrc files.
-   **Data Layer**:
    -   Built-in themes: `common/config/themes/<name>.json` (version-controlled).
    -   Custom themes: `polyterm-data/settings/themes/<name>.json` (user-private).
    -   Each JSON defines `colors` (18 ANSI tokens) and optional `fzf` overrides.
-   **Loading Chain**:
    1.  Shell profile sets `POLYTERM_THEME` (default: `peppermint`).
    2.  `themes.sh` looks for `<name>.json` in user themes dir first, then built-in dir.
    3.  Python helper extracts `colors` and `fzf` sub-objects.
    4.  `POLYTERM_FZF_*` and `POLYTERM_COLOR_*` env vars exported.
    5.  `build_fzf_opts()` constructs `FZF_DEFAULT_OPTS="--color=..."`.
-   **Theme Selection UI**: `settings.sh` → `theme_menu()` uses fzf to list available themes, calls `update_setting("POLYTERM_THEME", name)` + `load_theme(name)`.
-   **Custom Theme Editor**: `settings.sh` → `customize_theme_menu()` → `theme_color_editor()` with 18 color tokens, hex validation, save to `polyterm-data/settings/themes/<slug>.json`.
-   **Zellij Theme Editor**: A "Theme Colors..." entry in the Zellij Config Manager (`zellij_config_menu()`) provides interactive editing of 11 Zellij KDL color tokens via `kdl_config.py --get-theme-colors`/`--set-theme-color`. The editor copies the `.kdl` file, shows tokens in an fzf loop, validates hex input via `validate_hex()`, supports `default`/`reset` to restore original values. "Save" writes back to the `.kdl` file and calls `trigger_zsh_func "dot-zellij-reload"`.
-   **Failure Impact**: Corrupted theme JSON → `python3` JSON parse error → `load_theme` falls back to Peppermint silently.

### 5. Configuration Manager (Zellij)
-   **Location**: `common/palette/config_manager.sh`.
-   **Logic**: Reads Zellij `config.kdl` settings via `kdl_config.py --get`, displays them in an fzf menu with type metadata. Boolean/choice/string editing modes. Theme color editing via `--get-theme-colors`/`--set-theme-color`.
-   **Python Backend**: `kdl_config.py` handles KDL parsing, type detection, metadata lookup, and idempotent write-back.
-   **Failure Impact**: Corrupted `config.kdl` → `kdl_config.py` parse failure → empty settings list → menu shows only "Back".

### 6. Palette File Map
| File | Purpose | Key Functions |
| :--- | :--- | :--- |
| `helpers.sh` | Shared utilities | `update_setting`, `trigger_zsh_func`, `confirm_action`, `dot-zellij-reload` |
| `themes.sh` | Theme loader | `load_theme`, `list_themes`, `get_theme_color`, `get_theme_display_name` |
| `settings.sh` | System Preferences | `settings_menu`, `theme_menu`, `theme_color_editor` |
| `config_manager.sh` | Zellij config | `zellij_config_menu`, `zellij_theme_colors_menu`, `zellij_theme_color_editor` |
| `kdl_config.py` | KDL parser/writer | `--get`, `--set`, `--get-theme-colors`, `--set-theme-color` |

---

## 🛡️ Security & Integrity

### Security Scan (`dot-scan`)
-   **Logic**: Performs self-healing for security tools; automatically installs `shellcheck` or `lynis` if they are missing before running the audit.
-   **Integration**: Standardized as the pre-sync step for `dot-sync` across all platforms to ensure zero-vulnerability code pushes.
-   **Execution**: Uses absolute paths for `sudo` execution (e.g., `sudo /home/linuxbrew/.../lynis`) to ensure stability across environment variables.
-   **File Risk**: If `common/security.sh` is altered with malicious intent, it could execute unauthorized commands with elevated privileges.

### Dependency Chain
1.  **Shell** (`zshrc`) → loads **Functions** (`dot-sync`, `dot-pull`).
2.  **Tmux** (`tmux.conf`) → triggers **Scripts** (`palette.sh`).
3.  **Palette** (`palette.sh`) → sources **Library** (`common/palette/*.sh`).
4.  **Library** → executes **Shell Functions** (via `tmux send-keys`).

---

## 🛑 Failure Recovery

If critical configuration files are deleted or corrupted:
1.  **Manual Recovery**: Use `git checkout .` to restore files from the local repository.
2.  **Full Reinstall**: Run `polyterm setup` or the remote bootstrap command:
    `bash -c "$(curl -fsSL raw.githubusercontent.com/mmmonowar/dotfiles/main/application-package/install.sh)"`

---

## 🔧 Homebrew Formula

### Download Strategy

`Formula/polyterm.rb` uses a **git URL** with branch-based checkout. On WSL, Homebrew 6.0.12's `GitDownloadStrategy` triggers `Errno::EINVAL` during build staging (`/var/tmp/`). The formula overrides the `stage` method to perform a direct `git clone --depth=1` into the build directory using the **HTTPS URL** (`https://github.com/mmmonowar/dotfiles.git`), bypassing the buggy staging pipeline entirely. It sets `GIT_CONFIG_NOSYSTEM=1` and `GIT_CONFIG_GLOBAL=/dev/null` to bypass broken `.gitconfig` permissions (common on WSL after `sudo` operations). The repo is public — no authentication required. Shell scripts are enforced to LF line endings via `.gitattributes`.

```bash
brew update && brew install polyterm
```

This has no effect on `polyterm setup` or `dot-pull` — those operate on your personal `~/polyterm` clone independently.

### Explicit Directory Installs

The formula installs only the directories the CLI needs at runtime:
- `application-package/` → `setup`, `offboard`
- `common/` → `palette`, sync, security, configs
- `OS/` → Brewfiles, zshrc templates
- `docs/`, `README.md` → informational

Skipped: `bin/` (already installed by `bin.install`), `Formula/`, `data/`, hidden files.
