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
    echo -e "\n📦 ${YELLOW}Checking for outdated packages...${NC}"
    if brew outdated --quiet | grep -q .; then
        echo -e "⚠️  Outdated packages detected."
        echo -e "🔧 ${BLUE}Taking action: Upgrading packages...${NC}"
        brew upgrade
        brew cleanup
    else
        echo -e "✅ All packages are up to date."
    fi

    # 2. Homebrew Health Check
    echo -e "\n🍺 ${YELLOW}Running brew doctor...${NC}"
    if ! brew doctor > /dev/null 2>&1; then
        echo -e "⚠️  Homebrew reported some issues."
        brew doctor | grep -E "Warning|Error" || echo "Check 'brew doctor' for details."
        ISSUES_FOUND=$((ISSUES_FOUND + 1))
    else
        echo -e "✅ Homebrew environment is healthy."
    fi

    # 3. Static Analysis of Shell Scripts
    if command -v shellcheck &> /dev/null; then
        echo -e "\n🐚 ${YELLOW}Scanning shell scripts with shellcheck...${NC}"
        # Scan all .sh files and zshrc files in the repo
        local scripts=$(find "$DOT_PATH" -maxdepth 3 -name "*.sh" -o -name "*zshrc" -not -path "*/.git/*")
        local sc_errors=0
        for script in $scripts; do
            if ! shellcheck "$script"; then
                echo -e "❌ Issues found in ${BLUE}$script${NC}"
                sc_errors=$((sc_errors + 1))
            fi
        done
        if [ $sc_errors -eq 0 ]; then
            echo -e "✅ No critical shell script vulnerabilities found."
        else
            ISSUES_FOUND=$((ISSUES_FOUND + sc_errors))
        fi
    else
        echo -e "\n⚠️  shellcheck not found. Skipping script scan."
    fi

    # 4. Secret Scanning (Simple heuristic)
    echo -e "\n🔑 ${YELLOW}Scanning for potential secrets...${NC}"
    local secrets_found=$(grep -rEi "api_key|secret|password|token|auth" "$DOT_PATH" --exclude-dir=".git" --exclude="*.md" --exclude="Brewfile*" | grep -vE "GITHUB_TOKEN|#|//" | head -n 5)
    if [ -n "$secrets_found" ]; then
        echo -e "⚠️  ${RED}Potential secrets or sensitive keys found in files:${NC}"
        echo "$secrets_found"
        echo -e "... (showing first 5 results)"
        echo -e "💡 ${BLUE}Advice: Ensure these are environment variables or encrypted, not hardcoded.${NC}"
        ISSUES_FOUND=$((ISSUES_FOUND + 1))
    else
        echo -e "✅ No obvious hardcoded secrets detected."
    fi

    # 5. System Security Audit (Lynis)
    if command -v lynis &> /dev/null; then
        echo -e "\n🔎 ${YELLOW}Running system security audit (Lynis - quick check)...${NC}"
        # We run a subset of lynis or a quick audit to avoid it being too slow
        sudo lynis audit system --quick --no-log
    else
        echo -e "\n⚠️  lynis not found. Skipping system audit."
    fi

    echo -e "\n${BLUE}==========================================${NC}"
    if [ $ISSUES_FOUND -eq 0 ]; then
        echo -e "✨ ${GREEN}Security scan complete. No critical issues found!${NC}"
    else
        echo -e "🏁 ${YELLOW}Security scan complete with $ISSUES_FOUND warnings/issues.${NC}"
        echo -e "Please review the output above for recommended actions."
    fi
    echo -e "${BLUE}==========================================${NC}"
}
