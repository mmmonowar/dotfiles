#!/bin/bash

# ==========================================
#   ALT/OPTION KEY COMPATIBILITY FIX
# ==========================================

# OS Detection
if [[ "$OSTYPE" == "darwin"* ]]; then
    OS="mac"
elif uname -a | grep -iq "microsoft"; then
    OS="wsl"
elif uname -a | grep -iq "ubuntu"; then
    OS="ubuntu"
else
    OS="linux"
fi

echo "󰄀  Detected OS: $OS"

# --- Diagnostic Test ---
echo "------------------------------------------------"
echo "🔍 DIAGNOSTIC TEST: Press Alt+P now (or any Alt combo)"
echo "If you see '^[p', your terminal is correctly sending Meta sequences."
echo "If you see 'π' or nothing, it is NOT configured correctly."
echo "Press ENTER after testing to see the fix instructions."
printf "> "
if [ -n "$BASH_VERSION" ]; then
    read -n 3 test_key
elif [ -n "$ZSH_VERSION" ]; then
    read -k 3 test_key
else
    read test_key
fi
echo -e "\nReceived: $test_key"

if [[ "$OS" == "ubuntu" ]]; then
    echo "------------------------------------------------"
    echo "󰘳  Fixing Alt keys for Ubuntu (GNOME Terminal)..."
    echo "This will disable Alt menu shortcuts that intercept your Tmux bindings."
    
    if command -v gsettings &> /dev/null; then
        echo "🔄 Disabling menu accelerators..."
        gsettings set org.gnome.Terminal.Legacy.Settings menu-accelerator-enabled false
        echo "✅ Menu accelerators disabled."
    else
        echo "❌ gsettings not found. If you use GNOME, install it."
    fi

elif [[ "$OS" == "mac" ]]; then
    echo "------------------------------------------------"
    echo "󰘳  Fixing Alt/Option keys for macOS..."
    echo ""
    echo "🔧  FOR ITERM2 (Recommended):"
    echo "   1. Settings (Cmd+,) -> Profiles -> Keys"
    echo "   2. Set 'Left Option Key' to 'Esc+'"
    echo ""
    echo "🔧  FOR TERMINAL.APP:"
    echo "   1. Settings (Cmd+,) -> Profiles -> Keyboard"
    echo "   2. Check 'Use Option as Meta key'"

elif [[ "$OS" == "wsl" ]]; then
    echo "------------------------------------------------"
    echo "󰘳  WSL detected."
    echo "If Alt is not working, ensure your Terminal (Windows Terminal) "
    echo "doesn't have conflicting Alt bindings in its JSON settings."
fi

echo "------------------------------------------------"
echo "🔄 Reloading Tmux configuration..."
tmux source-file ~/.tmux.conf &> /dev/null
echo "✅ Done! All shortcuts now use the ALT key."
