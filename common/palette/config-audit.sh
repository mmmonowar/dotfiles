#!/bin/zsh

# ==========================================
# 🔍  CONFIG AUDIT & MERGE
# ==========================================
# Detects diverged managed config files and
# offers interactive merge via fzf.

_CA_ACTIONS=()

_ca_log()   { echo "  🔍 $*"; }
_ca_warn()  { echo "  ⚠️  $*" >&2; }
_ca_ok()    { echo "  ✅ $*"; }
_ca_fix()   { echo "  🔧 $*"; }
_ca_action(){ _CA_ACTIONS+=("$1"); }

_ca_managed_list() {
    local root="${1:-$DOTFILES_ROOT}"
    local os="${2:-$OS_ENV}"
    if [[ -z "$root" || ! -d "$root" ]]; then
        return 1
    fi
    local device_id="${3:-$(hostname | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9_-]//g')}"
    local zshrc_src="$root/OS/$os/zshrc"
    [[ -f "$root/OS/$os/$device_id/zshrc" ]] && zshrc_src="$root/OS/$os/$device_id/zshrc"

    cat <<EOF
$zshrc_src|$HOME/.zshrc
$root/common/config/tmux/tmux.conf|$HOME/.tmux.conf
$root/common/config/micro|$HOME/.config/micro
$root/common/config/gemini/settings.json|$HOME/.gemini/settings.json
$root/common/config/glow/glow.yml|$HOME/.config/glow/glow.yml
$root/common/config/zsh/plugins.txt|$HOME/.zsh_plugins.txt
$root/common/config/zellij/config.kdl|$HOME/.config/zellij/config.kdl
EOF
}

ca_check_symlinks() {
    local root="${1:-$DOTFILES_ROOT}"
    local os="${2:-$OS_ENV}"
    local all_ok=true

    if [[ -z "$root" || ! -d "$root" ]]; then
        _ca_warn "DOTFILES_ROOT not set or not a directory: $root"
        echo ""
        echo "  ┌─ Managed Config Diagnostics ────────────────────"
        echo "  │  DOTFILES_ROOT is not set."
        echo "  │  This audit requires DOTFILES_ROOT to find the"
        echo "  │  repo. Run 'polyterm setup' first, or manually"
        echo "  │  export DOTFILES_ROOT=/path/to/dotfiles"
        echo "  └────────────────────────────────────────────────┘"
        echo ""
        return 1
    fi

    echo ""
    echo "  ┌─ 🔍  Config Audit ────────────────────────────────"
    echo "  │  Repo: $root"
    echo "  └──────────────────────────────────────────────────"
    echo ""

    local device_id
    device_id=$(hostname | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9_-]//g')

    _ca_managed_list "$root" "$os" "$device_id" | while IFS='|' read -r src dest; do
        local display_name="${dest/#$HOME/~}"
        if [[ -L "$dest" ]]; then
            local target
            target=$(readlink "$dest")
            if [[ "$target" == "$src" ]]; then
                _ca_ok "$display_name → symlink OK"
            elif [[ "$target" == "$src" ]]; then
                _ca_ok "$display_name → symlink OK"
            else
                _ca_warn "$display_name → symlinks to $target (expected $src)"
                _ca_action "wrong-target"
                all_ok=false
            fi
        elif [[ -f "$dest" || -d "$dest" ]]; then
            if [[ -f "$src" ]]; then
                if diff -q "$src" "$dest" &>/dev/null; then
                    _ca_ok "$display_name → standalone file, content matches repo"
                else
                    local lines
                    lines=$(diff "$src" "$dest" 2>/dev/null | wc -l)
                    _ca_warn "$display_name → standalone file, CONTENT DIVERGED (~$lines lines differ)"
                    _ca_action "diverged"
                    all_ok=false
                fi
            elif [[ -d "$src" ]]; then
                if diff -qr "$src" "$dest" &>/dev/null; then
                    _ca_ok "$display_name → standalone dir, content matches repo"
                else
                    _ca_warn "$display_name → standalone dir, CONTENT DIVERGED"
                    _ca_action "diverged"
                    all_ok=false
                fi
            fi
        elif [[ ! -e "$dest" ]]; then
            _ca_warn "$display_name → MISSING"
            _ca_action "missing"
            all_ok=false
        fi
    done

    echo ""
    if $all_ok; then
        _ca_ok "All managed configs are correctly linked"
    else
        _ca_warn "Issues found — run polyterm config-audit --repair"
    fi
    echo ""

    $all_ok && return 0 || return 1
}

_ca_parse_hunks() {
    local diff_file="$1"
    awk '
    /^@@ / { if (hunk) print "HUNK:" hunk; hunk = $0; next }
    { hunk = hunk "\n" $0 }
    END { if (hunk) print "HUNK:" hunk }
    ' "$diff_file"
}

_ca_merge_file_interactive() {
    local src="$1"
    local dest="$2"
    local tmpdir
    tmpdir=$(mktemp -d)
    local diff_file="$tmpdir/merge.diff"
    local hunk_file="$tmpdir/hunks.txt"
    local local_file="$dest"
    local repo_file="$src"
    local basename
    basename=$(basename "$dest")
    local display_name="${dest/#$HOME/~}"

    diff -u "$local_file" "$repo_file" > "$diff_file" 2>/dev/null

    local total_lines
    total_lines=$(wc -l < "$diff_file")
    if [[ "$total_lines" -le 1 ]]; then
        _ca_ok "$display_name — no differences"
        rm -rf "$tmpdir"
        return 0
    fi

    _ca_parse_hunks "$diff_file" > "$hunk_file"
    local hunk_count
    hunk_count=$(grep -c '^HUNK:' "$hunk_file" || true)

    clear
    echo ""
    echo "  📄  $display_name"
    echo "  ───────────────────────────────────────────"
    echo "   Repo version: $src"
    echo "   $hunk_count section(s) differ."
    echo ""

    local choice
    choice=$(printf "Keep local (no changes)\nOverwrite with repo version\nView full diff\nMerge: select changes to apply" | fzf \
        --header="Config file $display_name has diverged from repo" \
        --prompt="Action > " \
        --preview="diff -u '$src' '$dest' | head -200" \
        --preview-window="right:60%" \
        --height=12 \
        --layout=reverse 2>/dev/null)

    case "$choice" in
        "Keep local (no changes)")
            _ca_log "Keeping local version of $display_name"
            _ca_action "kept-local-$basename"
            echo "$local_file"
            rm -rf "$tmpdir"
            return 0
            ;;
        "Overwrite with repo version")
            _ca_log "Replacing $display_name with repo version"
            cp "$repo_file" "$local_file" 2>/dev/null
            _ca_fix "Overwritten with repo version"
            _ca_action "overwritten-$basename"
            echo "$repo_file"
            rm -rf "$tmpdir"
            return 0
            ;;
        "View full diff")
            diff -u "$local_file" "$repo_file" | less -R
            _ca_merge_file_interactive "$src" "$dest"
            local ret=$?
            rm -rf "$tmpdir"
            return $ret
            ;;
        "Merge: select changes to apply")
            ;;
        *)
            rm -rf "$tmpdir"
            return 1
            ;;
    esac

    local filtered_diff="$tmpdir/filtered.diff"
    : > "$filtered_diff"

    local idx=0
    local selected_hunks=()
    local hunk_labels=()

    while IFS= read -r line; do
        if [[ "$line" == HUNK:* ]]; then
            local hunk_body="${line#HUNK:}"
            local header_line
            header_line=$(echo "$hunk_body" | head -1)
            hunk_labels+=("$((idx + 1)): $header_line")
            eval "hunk_$idx=\$hunk_body"
            ((idx++))
        fi
    done < "$hunk_file"

    if [[ "$hunk_count" -le 0 ]]; then
        _ca_warn "No changes found"
        rm -rf "$tmpdir"
        return 1
    fi

    local selected
    selected=$(printf '%s\n' "${hunk_labels[@]}" | fzf \
        --header="Select changes to APPLY from repo (SPACE to toggle, ENTER to confirm)" \
        --bind="space:toggle" \
        --multi \
        --preview="echo {} | sed 's/^[0-9]*: //' | cat - '$diff_file' 2>/dev/null | head -30" \
        --preview-window="right:60%" \
        --height=20 \
        --layout=reverse 2>/dev/null)

    if [[ -z "$selected" ]]; then
        _ca_log "No hunks selected — keeping local version"
        _ca_action "merge-skipped-$basename"
        echo "$local_file"
        rm -rf "$tmpdir"
        return 0
    fi

    echo "$diff_file" > "$tmpdir/full_diff.txt"

    local selected_indices=()
    while IFS= read -r sel; do
        local num
        num=$(echo "$sel" | sed 's/:.*//')
        selected_indices+=("$((num - 1))")
    done <<< "$selected"

    local temp_work="$tmpdir/work"
    cp "$local_file" "$temp_work"

    local applied=0
    for s_idx in "${selected_indices[@]}"; do
        local hunk_var="hunk_$s_idx"
        local body="${(P)hunk_var}"
        local hunk_header
        hunk_header=$(echo "$body" | head -1)

        local old_start
        old_start=$(echo "$hunk_header" | sed -n 's/@@ -\([0-9]*\).*/\1/p')
        local old_count
        old_count=$(echo "$hunk_header" | sed -n 's/@@ -\([0-9]*\),\?\([0-9]*\).*/\1/p')

        local hunk_diff="$tmpdir/hunk_${s_idx}.diff"
        echo "$body" > "$hunk_diff"

        if patch --force "$temp_work" "$hunk_diff" &>/dev/null; then
            ((applied++))
        fi
    done

    if [[ "$applied" -gt 0 ]]; then
        cp "$temp_work" "$local_file"
        _ca_fix "Applied $applied/${hunk_count} change(s) from repo to $display_name"
        _ca_action "merged-$applied-$basename"
    else
        _ca_log "No changes were applied to $display_name"
        _ca_action "merge-none-$basename"
    fi

    echo "$local_file"
    rm -rf "$tmpdir"
    return 0
}

ca_offer_merge() {
    local root="${1:-$DOTFILES_ROOT}"
    local os="${2:-$OS_ENV}"
    local non_interactive="${3:-false}"

    if [[ -z "$root" || ! -d "$root" ]]; then
        _ca_warn "DOTFILES_ROOT not set or not a directory: $root"
        return 1
    fi

    local device_id
    device_id=$(hostname | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9_-]//g')
    local any_merged=false

    _ca_managed_list "$root" "$os" "$device_id" | while IFS='|' read -r src dest; do
        local display_name="${dest/#$HOME/~}"

        if [[ -L "$dest" ]]; then
            local target
            target=$(readlink "$dest")
            if [[ "$target" == "$src" ]]; then
                continue
            fi
            _ca_warn "$display_name → wrong symlink target"
            continue
        fi

        if [[ ! -f "$src" && ! -d "$src" ]]; then
            _ca_warn "Repo source missing: $src"
            continue
        fi

        if [[ ! -e "$dest" ]]; then
            _ca_fix "$display_name → missing, creating symlink"
            ln -sf "$src" "$dest" 2>/dev/null || mkdir -p "$(dirname "$dest")" && ln -sf "$src" "$dest" 2>/dev/null
            _ca_action "created-$display_name"
            continue
        fi

        if [[ -f "$src" && -f "$dest" ]]; then
            if diff -q "$src" "$dest" &>/dev/null; then
                if [[ ! -L "$dest" ]]; then
                    _ca_fix "$display_name → content matches, replacing with symlink"
                    local bak="${dest}.bak.$(date +%s)"
                    mv "$dest" "$bak" 2>/dev/null
                    ln -sf "$src" "$dest" 2>/dev/null
                    _ca_action "symlinked-$display_name"
                fi
                continue
            fi

            _ca_warn "$display_name → CONTENT DIVERGED"
            if [[ "$non_interactive" == "true" ]]; then
                _ca_log "Non-interactive mode — skipping merge for $display_name"
                continue
            fi

            local result
            result=$(_ca_merge_file_interactive "$src" "$dest")
            if [[ -n "$result" && -f "$result" ]]; then
                local bak="${dest}.bak.$(date +%s)"
                cp "$dest" "$bak" 2>/dev/null
                mv "$result" "$dest" 2>/dev/null
                ln -sf "$src" "$dest" 2>/dev/null
                any_merged=true
            fi
        elif [[ -d "$src" && -d "$dest" ]]; then
            if diff -qr "$src" "$dest" &>/dev/null; then
                if [[ ! -L "$dest" ]]; then
                    _ca_fix "$display_name → dir content matches, replacing with symlink"
                    local bak="${dest}.bak.$(date +%s)"
                    mv "$dest" "$bak" 2>/dev/null
                    ln -sf "$src" "$dest" 2>/dev/null
                    _ca_action "symlinked-$display_name"
                fi
                continue
            fi
            _ca_warn "$display_name → directory diverged — manual merge needed"
            _ca_action "diverged-dir-$display_name"
        fi
    done

    if $any_merged; then
        _ca_ok "Config merge complete — some files were updated"
    fi
    return 0
}

ca_repair_symlinks() {
    local root="${1:-$DOTFILES_ROOT}"
    local os="${2:-$OS_ENV}"

    if [[ -z "$root" || ! -d "$root" ]]; then
        _ca_warn "DOTFILES_ROOT not set or not a directory: $root"
        return 1
    fi

    local device_id
    device_id=$(hostname | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9_-]//g')
    local repaired=false

    echo ""
    echo "  ┌─ 🔧  Config Repair ───────────────────────────────"
    echo ""

    _ca_managed_list "$root" "$os" "$device_id" | while IFS='|' read -r src dest; do
        local display_name="${dest/#$HOME/~}"

        if [[ -L "$dest" ]]; then
            local target
            target=$(readlink "$dest")
            if [[ "$target" == "$src" ]]; then
                _ca_ok "$display_name → OK"
                continue
            fi
            _ca_warn "$display_name → wrong target ($target)"
        elif [[ -e "$dest" ]]; then
            if diff -q "$src" "$dest" &>/dev/null 2>&1; then
                _ca_log "$display_name → content matches, replacing with symlink"
            else
                _ca_log "$display_name → content differs, backing up"
                local bak="${dest}.bak.$(date +%s)"
                mv "$dest" "$bak" 2>/dev/null
                _ca_action "backed-up-$display_name"
            fi
        else
            _ca_log "$display_name → missing, creating"
        fi

        mkdir -p "$(dirname "$dest")" 2>/dev/null
        if ln -sf "$src" "$dest" 2>/dev/null; then
            _ca_fix "$display_name → symlink repaired"
            _ca_action "repaired-$display_name"
            repaired=true
        else
            _ca_warn "$display_name → could not repair symlink"
        fi
    done

    echo ""
    if $repaired; then
        _ca_ok "Symlinks repaired. Run 'dot-reload' to apply."
    else
        _ca_ok "All symlinks OK"
    fi
    echo ""

    return 0
}

ca_run_audit() {
    local root="${1:-$DOTFILES_ROOT}"
    local os="${2:-$OS_ENV}"
    ca_check_symlinks "$root" "$os"

    echo ""
    echo "  ┌─ 🔍  Config Audit Summary ────────────────────────"
    if [[ ${#_CA_ACTIONS[@]} -eq 0 ]]; then
        _ca_ok "All configs are correctly managed"
    else
        echo "  Actions: ${_CA_ACTIONS[*]}"
        echo ""
        _ca_log "Run 'polyterm config-audit --repair' to fix issues"
        _ca_log "Run 'polyterm config-audit --merge' to merge diverged files"
    fi
    echo "  └──────────────────────────────────────────────────"
    echo ""
}
