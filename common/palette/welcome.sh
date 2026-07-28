#!/bin/bash

# ==========================================
#  WELCOME BANNER
# ==========================================
# Displays the PolyTerm ASCII art welcome banner at shell startup
# and after the `clear` command. Theme-aware coloring via POLYTERM_COLOR_*.

function polyterm_welcome() {
    [[ "${POLYTERM_WELCOME:-on}" == "off" ]] && return 0
    [[ -z "$DOTFILES_ROOT" ]] && return 0

    if (( ${+functions[is_agent_or_non_interactive]} )); then
        is_agent_or_non_interactive && return 0
    else
        [[ $- != *i* ]] && return 0
        [[ "$TERM" == "dumb" ]] && return 0
        [[ ! -t 1 ]] && return 0
    fi

    local banner_file
    case "$TERM" in
        linux|vt100|dumb|cons25|cygwin)
            banner_file="$DOTFILES_ROOT/common/config/polyterm/banner-tty.txt"
            ;;
        *)
            banner_file="$DOTFILES_ROOT/common/config/polyterm/banner-general.txt"
            ;;
    esac

    [[ ! -f "$banner_file" ]] && return 0

    local _date _time _hostname _os_env _sysname _shell _machine _load _users
    _date=$(date +"%Y-%m-%d")
    _time=$(date +"%H:%M:%S")
    _hostname=$(hostname -s 2>/dev/null || hostname)
    _os_env="${OS_ENV:-unknown}"
    _sysname=$(uname -s)
    _shell=$(basename "${SHELL:-zsh}")
    _machine=$(uname -m)
    _load=$(uptime | sed 's/.*load average: /Load: /' 2>/dev/null || echo "Load: n/a")
    _users=$(whoami)

    local _accent="${POLYTERM_COLOR_cyan:-#14b8a6}"
    local _dim="${POLYTERM_COLOR_brightBlack:-#2a2a2a}"

    local _hr _hg _hb _dr _dg _db
    _hr=$((16#${_accent:1:2})); _hg=$((16#${_accent:3:2})); _hb=$((16#${_accent:5:2}))
    _dr=$((16#${_dim:1:2}));   _dg=$((16#${_dim:3:2}));   _db=$((16#${_dim:5:2}))

    local c_accent="\033[38;2;${_hr};${_hg};${_hb}m"
    local c_dim="\033[38;2;${_dr};${_dg};${_db}m"
    local c_reset="\033[0m"

    local line idx=0
    while IFS= read -r line || [[ -n "$line" ]]; do
        ((idx++))

        line="${line//\\d/$_date}"
        line="${line//\\t/$_time}"
        line="${line//\\n/$_hostname}"
        line="${line//\\o/$_os_env}"
        line="${line//\\S/$_sysname}"
        line="${line//\\s/$_shell}"
        line="${line//\\m/$_machine}"
        line="${line//\\l/$_load}"
        line="${line//\\u/$_users}"

        if [[ "$line" == *"P O L Y O S"* ]]; then
            printf '%b%s%b\n' "$c_accent" "$line" "$c_reset"
        elif [[ "$line" == "=="* ]] || [[ "$line" == " ="* ]]; then
            printf '%b%s%b\n' "$c_dim" "$line" "$c_reset"
        elif [[ "$line" == *"Copyright"* ]]; then
            printf '%b%s%b\n' "$c_dim" "$line" "$c_reset"
        else
            printf '%s\n' "$line"
        fi
    done < "$banner_file"
}

function polyterm_clear() {
    \clear
    polyterm_welcome
}
