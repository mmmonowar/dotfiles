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

    terminal=""
    if [[ "$TERM_PROGRAM" == "Apple_Terminal" ]]; then
        terminal="terminal.app"
    elif [[ "$TERM_PROGRAM" == "iTerm.app" ]] || [[ -n "$ITERM_SESSION_ID" ]]; then
        terminal="iterm2"
    elif [[ -n "$WARP_IS_LOCAL_SHELL" ]]; then
        terminal="warp"
    else
        terminal="unknown"
    fi

    echo "  Detected terminal: $terminal"

    if [[ "$terminal" == "terminal.app" ]]; then
        current=$(defaults read com.apple.Terminal "Use Option as Meta Key" 2>/dev/null)
        if [[ "$current" == "1" ]] || [[ "$current" == "true" ]] || [[ "$current" == "YES" ]]; then
            echo "  ✅  Alt keys already configured."
        else
            echo "  🔄  Enabling 'Use Option as Meta key'..."
            defaults write com.apple.Terminal "Use Option as Meta Key" -bool true
            echo "  ✅  Option Key now sends Meta (Esc+)."
            echo "      Applies to new Terminal windows."
        fi

    elif [[ "$terminal" == "iterm2" ]]; then
        plist="$HOME/Library/Preferences/com.googlecode.iterm2.plist"
        if [ -f "$plist" ]; then
            current=$(/usr/libexec/PlistBuddy -c "Print :New Bookmarks:0:Option Key Sends" "$plist" 2>/dev/null)
            if [[ "$current" == "2" ]]; then
                echo "  ✅  Alt keys already configured (Esc+)."
            else
                echo "  🔄  Setting Left Option Key to Esc+..."
                /usr/libexec/PlistBuddy -c "Set :New Bookmarks:0:Option Key Sends 2" "$plist" 2>/dev/null || \
                /usr/libexec/PlistBuddy -c "Add :New Bookmarks:0:Option Key Sends integer 2" "$plist" 2>/dev/null
                echo "  ✅  Option Key now sends Esc+."
                echo "      Restart iTerm2 or open a new window."
            fi
        else
            echo "  ⚠️  iTerm2 plist not found. Using custom prefs folder?"
            echo "      Set manually: Settings -> Profiles -> Keys -> Left Option Key -> Esc+"
        fi

    else
        echo "  ⚠️  Terminal not detected (e.g. SSH session). Trying both fixes..."
        echo ""
        echo "  🔄  Enabling Terminal.app Option as Meta..."
        defaults write com.apple.Terminal "Use Option as Meta Key" -bool true 2>/dev/null || true

        plist="$HOME/Library/Preferences/com.googlecode.iterm2.plist"
        if [ -f "$plist" ]; then
            echo "  🔄  Setting iTerm2 Left Option Key to Esc+..."
            /usr/libexec/PlistBuddy -c "Set :New Bookmarks:0:Option Key Sends 2" "$plist" 2>/dev/null || \
            /usr/libexec/PlistBuddy -c "Add :New Bookmarks:0:Option Key Sends integer 2" "$plist" 2>/dev/null
        fi

        echo "  ✅  Both fixes applied (harmless if app not installed)."
        echo "      Open a new terminal window or SSH session to test."
    fi

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
