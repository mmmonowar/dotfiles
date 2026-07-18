#!/bin/bash

# ==========================================
#  THEME LOADER
#   - Reads POLYTERM_THEME, loads matching JSON
#   - Exports FZF color variables
#   - Provides theme list/editor helpers
# ==========================================

POLYTERM_THEMES_DIR="${REPO_PATH:-$DOTFILES_ROOT}/common/config/themes"
POLYTERM_USER_THEMES_DIR="${DOTFILES_DATA}/settings/themes"

POLYTERM_THEME="${POLYTERM_THEME:-peppermint}"

function validate_hex() {
    local val="$1"
    [[ "$val" =~ ^#[0-9a-fA-F]{6}$ ]]
}

function _theme_get() {
    local key="$1"
    local file="$2"
    python3 -c "
import json, sys
try:
    d = json.load(open(sys.argv[1]))
    print(d.get(sys.argv[2], ''))
except: sys.exit(1)
" "$file" "$key" 2>/dev/null
}

function _theme_get_nested() {
    local parent="$1"
    local child="$2"
    local file="$3"
    python3 -c "
import json, sys
try:
    d = json.load(open(sys.argv[1]))
    print(d.get(sys.argv[2], {}).get(sys.argv[3], ''))
except: sys.exit(1)
" "$file" "$parent" "$child" 2>/dev/null
}

function get_theme_color() {
    local key="$1"
    local theme_name="${2:-$POLYTERM_THEME}"
    local theme_file

    theme_file="$POLYTERM_USER_THEMES_DIR/$theme_name.json"
    if [[ ! -f "$theme_file" ]]; then
        theme_file="$POLYTERM_THEMES_DIR/$theme_name.json"
    fi
    if [[ ! -f "$theme_file" ]]; then
        theme_file="$POLYTERM_THEMES_DIR/peppermint.json"
    fi

    _theme_get "$key" "$theme_file"
}

function get_theme_fzf_color() {
    local key="$1"
    local theme_name="${2:-$POLYTERM_THEME}"
    local theme_file

    theme_file="$POLYTERM_USER_THEMES_DIR/$theme_name.json"
    if [[ ! -f "$theme_file" ]]; then
        theme_file="$POLYTERM_THEMES_DIR/$theme_name.json"
    fi
    if [[ ! -f "$theme_file" ]]; then
        theme_file="$POLYTERM_THEMES_DIR/peppermint.json"
    fi

    local value
    value=$(_theme_get_nested "fzf" "$key" "$theme_file")
    if [[ -n "$value" ]]; then
        echo "$value"
        return
    fi

    value=$(_theme_get "$key" "$theme_file")
    if [[ -n "$value" ]]; then
        echo "$value"
        return
    fi

    echo ""
}

function load_theme() {
    local theme_name="${1:-$POLYTERM_THEME}"
    local force_source=""
    local theme_file

    if [[ "$theme_name" == :builtin:* ]]; then
        force_source="builtin"
        theme_name="${theme_name#:builtin:}"
    elif [[ "$theme_name" == :custom:* ]]; then
        force_source="custom"
        theme_name="${theme_name#:custom:}"
    fi

    if [[ "$force_source" == "builtin" ]]; then
        theme_file="$POLYTERM_THEMES_DIR/$theme_name.json"
    elif [[ "$force_source" == "custom" ]]; then
        theme_file="$POLYTERM_USER_THEMES_DIR/$theme_name.json"
    else
        theme_file="$POLYTERM_USER_THEMES_DIR/$theme_name.json"
        if [[ ! -f "$theme_file" ]]; then
            theme_file="$POLYTERM_THEMES_DIR/$theme_name.json"
        fi
    fi
    if [[ ! -f "$theme_file" ]]; then
        theme_file="$POLYTERM_THEMES_DIR/peppermint.json"
        theme_name="peppermint"
    fi

    for var in $(env | grep '^POLYTERM_COLOR_\|^POLYTERM_FZF_' | cut -d= -f1); do
        unset "$var" 2>/dev/null || true
    done

    POLYTERM_THEME="$theme_name"
    export POLYTERM_THEME

    local key value
    while IFS='=' read -r key value; do
        if [[ -n "$key" && -n "$value" ]]; then
            export "POLYTERM_COLOR_${key}=${value}"
        fi
    done < <(python3 -c "
import json, sys
d = json.load(open(sys.argv[1]))
for k, v in d.get('colors', {}).items():
    print(f'{k}={v}')
" "$theme_file" 2>/dev/null)

    while IFS='=' read -r key value; do
        if [[ -n "$key" && -n "$value" ]]; then
            local sanitized_key=$(echo "$key" | tr '+.' '_')
            export "POLYTERM_FZF_${sanitized_key}=${value}"
        fi
    done < <(python3 -c "
import json, sys
d = json.load(open(sys.argv[1]))
for k, v in d.get('fzf', {}).items():
    print(f'{k}={v}')
" "$theme_file" 2>/dev/null)

    build_fzf_opts
}

function build_fzf_opts() {
    local opts=""
    local color_vars
    color_vars=$(env | grep '^POLYTERM_FZF_' | sed 's/^POLYTERM_FZF_//')
    while IFS='=' read -r key value; do
        if [[ -n "$key" && -n "$value" ]]; then
            local fzf_key=$(echo "$key" | tr '_' '+')
            opts+="${fzf_key}:${value},"
        fi
    done <<< "$color_vars"
    opts="${opts%,}"
    export FZF_DEFAULT_OPTS="--color=$opts"
}

function list_themes() {
    local builtin user_themes
    builtin=$(find "$POLYTERM_THEMES_DIR" -maxdepth 1 -name '*.json' -exec basename {} .json \; 2>/dev/null | sort)
    user_themes=$(find "$POLYTERM_USER_THEMES_DIR" -maxdepth 1 -name '*.json' -exec basename {} .json \; 2>/dev/null | sort)

    {
        echo "$builtin"
        echo "$user_themes"
    } | sort -u
}

function theme_exists() {
    local name="$1"
    [[ -f "$POLYTERM_THEMES_DIR/$name.json" || -f "$POLYTERM_USER_THEMES_DIR/$name.json" ]]
}

function save_user_theme() {
    local name="$1"
    local file="$POLYTERM_USER_THEMES_DIR/$name.json"
    mkdir -p "$POLYTERM_USER_THEMES_DIR"
    cat > "$file"
    echo "Saved theme '$name' to $file"
}

function get_theme_display_name() {
    local theme_name="$1"
    local theme_file

    theme_file="$POLYTERM_USER_THEMES_DIR/$theme_name.json"
    if [[ ! -f "$theme_file" ]]; then
        theme_file="$POLYTERM_THEMES_DIR/$theme_name.json"
    fi
    if [[ ! -f "$theme_file" ]]; then
        echo "$theme_name"
        return
    fi

    local name
    name=$(_theme_get "name" "$theme_file")
    echo "${name:-$theme_name}"
}

function get_theme_colors_json() {
    local theme_name="$1"
    local theme_file

    theme_file="$POLYTERM_USER_THEMES_DIR/$theme_name.json"
    if [[ ! -f "$theme_file" ]]; then
        theme_file="$POLYTERM_THEMES_DIR/$theme_name.json"
    fi

    if [[ -f "$theme_file" ]]; then
        python3 -c "
import json, sys
d = json.load(open(sys.argv[1]))
colors = d.get('colors', {})
fzf_colors = d.get('fzf', {})
print(json.dumps({'colors': colors, 'fzf': fzf_colors}))
" "$theme_file" 2>/dev/null
    fi
}

load_theme
