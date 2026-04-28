#!/bin/bash

# ==========================================
# 🛡️  DOTFILES SECURITY SCANNER
# ==========================================

function dot-scan() {
    echo -e "${BLUE}==========================================${NC}"
    echo -e "🛡️  Starting Security Vulnerability Scan"
    echo -e "${BLUE}==========================================${NC}"

    local DOT_PATH="$DOTFILES_ROOT"
    local ISSUES_FOUND=0

    # 1. Check for Outdated Packages (Fix: Auto-Upgrade)
    echo -e "\n󰏔  ${YELLOW}Checking for outdated packages...${NC}"
    if brew outdated --quiet | grep -q .; then
        echo -e "󰀦  Outdated packages detected."
        echo -e "󰒓  ${BLUE}Taking action: Upgrading packages...${NC}"
        brew upgrade
        brew cleanup
    else
        echo -e "󰄬  All packages are up to date."
    fi

    # 2. Homebrew Health Check
    echo -e "\n󰇊  ${YELLOW}Running brew doctor...${NC}"
    if ! brew doctor > /dev/null 2>&1; then
        echo -e "󰀦  Homebrew reported some issues."
        brew doctor | grep -E "Warning|Error" || echo "Check 'brew doctor' for details."
        ISSUES_FOUND=$((ISSUES_FOUND + 1))
    else
        echo -e "󰄬  Homebrew environment is healthy."
    fi

    # 3. Static Analysis of Shell Scripts
    if ! command -v shellcheck &> /dev/null; then
        echo -e "\n󰍉  ${YELLOW}shellcheck not found. Installing...${NC}"
        brew install shellcheck
    fi

    if command -v shellcheck &> /dev/null; then
        echo -e "\n󱆃  ${YELLOW}Scanning shell scripts with shellcheck...${NC}"
        # Scan all .sh files and zshrc files in the repo
        local sc_errors=0
        while IFS= read -r script; do
            if [ -n "$script" ]; then
                if ! shellcheck "$script"; then
                    echo -e "󰅙  Issues found in ${BLUE}$script${NC}"
                    sc_errors=$((sc_errors + 1))
                fi
            fi
        done < <(find "$DOT_PATH" -maxdepth 3 -name "*.sh" -o -name "*zshrc" -not -path "*/.git/*")
        
        if [ "$sc_errors" -eq 0 ]; then
            echo -e "󰄬  No critical shell script vulnerabilities found."
        else
            ISSUES_FOUND=$((ISSUES_FOUND + sc_errors))
        fi
    else
        echo -e "\n󰀦  shellcheck not found. Skipping script scan."
    fi

    # 4. Secret Scanning (Simple heuristic)
    echo -e "\n󰌆  ${YELLOW}Scanning for potential secrets...${NC}"
    # We exclude the scanner itself and common non-sensitive environment variables
    local secrets_found
    secrets_found=$(grep -rEi "api_key|secret|password|token|auth" "$DOT_PATH" \
        --exclude-dir=".git" \
        --exclude="*.md" \
        --exclude="Brewfile*" \
        --exclude="security.sh" | \
        grep -vE "GITHUB_TOKEN|SSH_AUTH_SOCK|COLORTERM|MICRO_TRUECOLOR|#|//" | \
        head -n 5)
    if [ -n "$secrets_found" ]; then
        echo -e "󰀦  ${RED}Potential secrets or sensitive keys found in files:${NC}"
        echo "$secrets_found"
        echo -e "... (showing first 5 results)"
        echo -e "󰌵  ${BLUE}Advice: Ensure these are environment variables or encrypted, not hardcoded.${NC}"
        ISSUES_FOUND=$((ISSUES_FOUND + 1))
    else
        echo -e "󰄬  No obvious hardcoded secrets detected."
    fi

    # 5. System Security Audit (Lynis)
    if ! command -v lynis &> /dev/null; then
        echo -e "\n󰍉  ${YELLOW}lynis not found. Installing...${NC}"
        brew install lynis
    fi

    if command -v lynis &> /dev/null; then
        echo -e "\n󰍉  ${YELLOW}Running system security audit (Lynis - quick check)...${NC}"
        
        # Self-healing for Lynis permissions on Homebrew
        # Lynis requires its files to be owned by root when running with sudo
        local LYNIS_PATH
        LYNIS_PATH=$(command -v lynis)
        if [[ "$LYNIS_PATH" == *"/linuxbrew/"* || "$LYNIS_PATH" == *"/Cellar/"* ]]; then
             local LYNIS_BASE_DIR
             LYNIS_BASE_DIR=$(dirname "$(dirname "$LYNIS_PATH")")
             if [ -d "$LYNIS_BASE_DIR/include" ]; then
                 # If the include directory is not owned by root, fix it
                 # We use sudo to check ownership to avoid platform-specific stat flags
                 if ! sudo [ -O "$LYNIS_BASE_DIR/include" ]; then
                     echo -e "🩹  ${BLUE}Heal: Aligning Lynis permissions for root execution...${NC}"
                     sudo chown -R 0:0 "$LYNIS_BASE_DIR" 2>/dev/null || true
                 fi
             fi
        fi

        # Use absolute path for sudo because Homebrew bin might not be in sudo's PATH
        local LYNIS_CMD
        LYNIS_CMD=$(command -v lynis)
        sudo "$LYNIS_CMD" audit system --quick --no-log
    fi

    echo -e "\n${BLUE}==========================================${NC}"
    if [ $ISSUES_FOUND -eq 0 ]; then
        echo -e "󱐋  ${GREEN}Security scan complete. No critical issues found!${NC}"
    else
        echo -e "🏁  ${YELLOW}Security scan complete with $ISSUES_FOUND warnings/issues.${NC}"
        echo -e "Please review the output above for recommended actions."
    fi
    echo -e "${BLUE}==========================================${NC}"
}
