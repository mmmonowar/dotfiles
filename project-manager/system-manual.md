# 🛠️ PolyTerm System Manual

This document provides a technical overview of the PolyTerm architecture, file purposes, and system interdependencies for developers and administrators.

---

## 🏗️ System Architecture Overview

PolyTerm is designed as a modular, cross-platform terminal environment. It uses a "Core + OS-Layer" approach:
1.  **Core (`common/`)**: Shared logic and configurations used across all platforms.
2.  **OS-Layer (`linux/`, `mac/`, `wsl/`)**: Platform-specific entry points and package definitions.
3.  **CLI Interface (`bin/polyterm`)**: A wrapper that exposes system functions to the user.
4.  **Automation Layer**: Shell functions (`dot-sync`, `dot-pull`) that handle Git and Homebrew synchronization.

---

## 📂 Directory & File Map

### 1. Root Directory
| Path | Purpose | Criticality | If Damaged/Deleted |
| :--- | :--- | :--- | :--- |
| `bin/polyterm` | Main entry point for the `polyterm` command. | **High** | The `polyterm` command will fail; manual environment management required. |
| `DESIGN.md` | Single source of truth for the Peppermint design system. | Medium | Aesthetic inconsistency across components; design drift. |
| `GEMINI.md` | Project-specific instructions for the Gemini CLI agent. | Low | Agent will lose context on repo-specific standards and automation. |
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

### 3. OS-Specific Directories (`linux/`, `mac/`, `wsl/`)
| Path | Purpose | Interdependencies | If Damaged/Deleted |
| :--- | :--- | :--- | :--- |
| `zshrc` | Primary shell configuration for the platform. | Sources `common/` logic | Shell startup fails; aliases, functions, and prompt settings lost. |
| `Brewfile.core` | Essential system packages (Git, Tmux, FZF). | Used by `dot-sync` (Healing) | Core tools cannot be automatically reinstalled or updated. |
| `Brewfile.apps` | User-installed CLI tools and apps. | Managed by Palette + `dot-sync` | Application list is lost; difficult to reproduce the environment. |
| `apps_meta.txt` | Cached descriptions for the App Launcher. | Used by `palette.sh` | Palette becomes slow as it fetches descriptions from Homebrew. |

---

## 🔄 Core Workflows & Logic

### 1. Self-Healing Sync (`dot-sync`)
-   **Location**: Defined in `[os]/zshrc`.
-   **Logic**: Before updating the `Brewfile`, it runs `brew bundle check`. If unsatisfied, it automatically runs `brew bundle` to install/update dependencies.
-   **Failure Impact**: If the healing logic is corrupted, users might push incomplete configurations or use an out-of-sync environment.

### 2. Integrated Reloading (`dot-reload`)
-   **Location**: Defined in `[os]/zshrc`.
-   **Logic**: Sources the local `.zshrc` and explicitly triggers `tmux source-file ~/.tmux.conf`.
-   **Improvement**: It now detects if a Tmux server is running and reloads the configuration even if the command is executed from a standard shell pane, ensuring consistent environment state.

### 3. Command Palette UI
-   **Location**: `common/palette.sh` (Entry) → `common/palette/*.sh` (Implementation).
-   **Logic**: Uses `fzf` with `--ansi`. Settings are persisted in `common/config/polyterm/.polyterm_settings`.
-   **Failure Impact**: Corruption leads to UI rendering issues or script execution errors when selecting menu items.

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
