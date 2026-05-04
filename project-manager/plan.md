# Project Plan

## Current Implementation State

### 1. Environment Setup
- **Goal**: Ensure seamless transition between macOS and WSL.
- **Steps**:
    - [x] Map shared configurations to `common/`.
    - [x] Create entry points in `mac/.zshrc` and `wsl/zshrc`.
    - [x] Configure automated Zsh + Tmux cockpit entry upon terminal launch.

### 2. Interface Layer
- **Goal**: Provide a GUI-like experience in the terminal.
- **Steps**:
    - [x] Script the `palette.sh` logic.
    - [x] Configure `tmux` popup dimensions and keybindings.
    - [x] Implement dynamic metadata (blurb) fetching for apps.
    - [x] Integrate an interactive "Execute Shortcut" menu in the palette.
    - [x] Refine UI ergonomics (Nerd Fonts, alignment, and safety prompts).
    - [x] Implement dedicated Scratchpad Settings menu for cross-platform path management.
    - [x] Implement centralized Peppermint Design System and theme synchronization.

### 3. Workflow Automation
- **Goal**: Minimize manual git and package maintenance.
- **Steps**:
    - [x] Standardize `dot-pull` and `dot-sync` across platforms.
    - [x] Integrate automated `hledger` journal synchronization and symbolic linking into `dot-sync`.
    - [x] Integrate `brew bundle dump` into `dot-sync`.
    - [x] Integrate `brew bundle` into `dot-pull`.
    - [x] Automate `dot-sync` within the Command Palette for package operations.
    - [x] Enhance Tmux session management workflows.

### 4. PolyMark Syntax & Theme Translation
- **Goal**: Synchronize Micro editor styles with the master Sublime PolyMark definition.
- **Strategy**:
    - [x] Analyze the nested contexts in `polymark.sublime-syntax` (e.g., `main`, `area-slash-project`).
    - [x] Flatten or map these to Micro's regex-based `rules`.
    - [x] Extract hex codes from `polymark.sublime-color-scheme` variables and rules.
    - [x] Construct the `PolyMark.micro` file using the extracted colors, mapping them to standard Micro color links.
    - [x] Update `PolyMark.yaml` with the comprehensive regex patterns from the Sublime syntax file.
    - [x] Create symbolic links from `~/dotfiles/common/micro/` to `~/.config/micro/` for deployment.

### 5. Troubleshooting & Compatibility
- **Goal**: Fix the monochrome issue and keybinding conflicts.
- **Steps**:
    - [x] Update `tmux.conf` for explicit TrueColor support.
    - [x] Configure shell profiles (`.zshrc`) to export TrueColor variables.
    - [x] Enable TrueColor in Micro's internal settings.
    - [x] Implement `fix-alt-keys.sh` for macOS and Ubuntu shortcut compatibility.
    - [x] Unify all shortcuts on the Alt (Meta) key across all platforms.
    - [x] Integrate Alt key fix into the Command Palette.

### 6. Deployment & Onboarding
- **Goal**: Enable rapid setup on new machines.
- **Steps**:
    - [x] Create a unified `install.sh` bootstrap script.
    - [x] Implement generic Linux support (`linux/zshrc`).
    - [x] Enable remote installation via `curl | bash`.
    - [ ] Implement automated health checks for symbolic links.

### 7. Security & Vulnerability Management
- **Goal**: Ensure the environment is secure and free of vulnerabilities.
- **Steps**:
    - [x] Create a dedicated `dot-scan` security function.
    - [x] Implement static analysis for shell scripts using `shellcheck`.
    - [x] Automate package vulnerability checks and system audits (`lynis`).
    - [x] Integrate secret detection to prevent hardcoded credential exposure.
    - [x] Embed security checks into the core installation and sync workflows.

### 8. Maintenance & Optimization (Ongoing)
- **Goal**: Ensure long-term stability and performance.
- **Steps**:
    - [x] Convert hardcoded repository paths to relative/dynamic paths for portability.
    - [x] Implement conditional AI model aliases and billing tracking to optimize LLM usage costs.
    - [ ] Research methods to speed up `brew bundle dump`.
    - [ ] Audit configurations for cross-platform redundancies.
