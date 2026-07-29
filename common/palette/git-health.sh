#!/bin/zsh

# ==========================================
# 🩺  GIT HEALTH CHECK & AUTO-HEAL
# ==========================================
# Detects and resolves common git issues:
#   - Stale MERGE_HEAD
#   - Dirty working tree
#   - Lock files
#   - Bogus filenames (control chars)
#   - CRLF in shell scripts
#   - Missing .git or origin remote
#   - Ahead/behind status
# ==========================================

_GIT_HEALTH_ACTIONS=()

_gh_log() {
    echo "  🩺 $*"
}

_gh_warn() {
    echo "  ⚠️  $*" >&2
}

_gh_ok() {
    echo "  ✅ $*"
}

_gh_fix() {
    echo "  🔧 $*"
}

_gh_action() {
    _GIT_HEALTH_ACTIONS+=("$1")
}

gh-check-stale-merge() {
    local dir="${1:-.}"
    if [[ -f "$dir/.git/MERGE_HEAD" ]]; then
        _gh_warn "Stale MERGE_HEAD detected (unfinished merge)"
        if git -C "$dir" merge --abort 2>/dev/null; then
            _gh_fix "Aborted stale merge"
            _gh_action "merge-abort"
        else
            _gh_warn "Could not abort merge — manual intervention needed"
            return 1
        fi
    else
        _gh_ok "No stale MERGE_HEAD"
    fi
    return 0
}

gh-check-lock() {
    local dir="${1:-.}"
    if [[ -f "$dir/.git/index.lock" ]]; then
        if pgrep -f "git.*$dir" >/dev/null 2>&1; then
            _gh_warn "index.lock exists and git process is running — skipping"
            return 1
        else
            _gh_warn "Stale index.lock detected"
            rm -f "$dir/.git/index.lock"
            _gh_fix "Removed stale index.lock"
            _gh_action "lock-removed"
        fi
    else
        _gh_ok "No lock files"
    fi
    return 0
}

gh-check-dirty() {
    local dir="${1:-.}"
    local stash_msg="polyterm:auto-$(date +%s)"
    if ! git -C "$dir" diff --quiet --ignore-submodules 2>/dev/null; then
        _gh_warn "Uncommitted changes detected"
        if git -C "$dir" stash push -m "$stash_msg" --include-untracked 2>/dev/null; then
            _gh_fix "Stashed uncommitted changes (pop after operation)"
            _gh_action "stash-push"
            echo "$stash_msg"
            return 0
        else
            _gh_warn "Could not stash changes — manual commit/stash needed"
            return 1
        fi
    fi
    if ! git -C "$dir" diff --cached --quiet 2>/dev/null; then
        _gh_warn "Staged but uncommitted changes detected"
        if git -C "$dir" stash push -m "$stash_msg" --staged 2>/dev/null; then
            _gh_fix "Stashed staged changes (pop after operation)"
            _gh_action "stash-push"
            echo "$stash_msg"
            return 0
        fi
    fi
    _gh_ok "Working tree clean"
    echo ""
    return 0
}

gh-stash-pop() {
    local dir="${1:-.}"
    local stash_msg="$2"
    if [[ -z "$stash_msg" ]]; then
        return 0
    fi
    if git -C "$dir" stash list | grep -q "$stash_msg"; then
        if git -C "$dir" stash pop 2>/dev/null; then
            _gh_fix "Restored stashed changes"
            _gh_action "stash-pop"
        else
            _gh_warn "Could not pop stash — manual intervention: git stash pop"
        fi
    fi
}

gh-check-bogus-filenames() {
    local dir="${1:-.}"
    local found=0
    while IFS= read -r line; do
        local file=$(echo "$line" | cut -d' ' -f2-)
        if echo "$file" | grep -q $'[\x00-\x08\x0b\x0c\x0e-\x1f]'; then
            _gh_warn "Bogus filename: $file"
            if git -C "$dir" rm --cached "$file" 2>/dev/null; then
                rm -f "$dir/$file" 2>/dev/null
                _gh_fix "Removed from index and working tree"
                _gh_action "bogus-removed"
            fi
            found=1
        fi
    done < <(git -C "$dir" ls-files --stage 2>/dev/null | grep $'[\x00-\x08\x0b\x0c\x0e-\x1f]' || true)
    if [[ "$found" -eq 0 ]]; then
        _gh_ok "No bogus filenames"
    fi
    return 0
}

gh-check-crlf() {
    local dir="${1:-.}"
    local found=0
    while IFS= read -r file; do
        if [[ -f "$dir/$file" ]]; then
            if grep -l $'\r$' "$dir/$file" &>/dev/null; then
                _gh_warn "CRLF in: $file"
                tr -d $'\r' < "$dir/$file" > "$dir/${file}.tmp" && mv "$dir/${file}.tmp" "$dir/$file"
                _gh_fix "Converted to LF"
                _gh_action "crlf-fixed"
                found=1
            fi
        fi
    done < <(git -C "$dir" ls-files 2>/dev/null | grep -E '\.(sh|zshrc|bashrc|conf)$' || true)
    if [[ "$found" -eq 0 ]]; then
        _gh_ok "All shell files have LF line endings"
    fi
    return 0
}

gh-check-repo() {
    local dir="${1:-.}"
    local ok=true
    if [[ ! -d "$dir/.git" ]]; then
        _gh_warn "Not a git repository (no .git directory)"
        ok=false
    else
        _gh_ok "Git repository found"
    fi

    if ! git -C "$dir" remote get-url origin &>/dev/null; then
        _gh_warn "No 'origin' remote configured"
        ok=false
    else
        _gh_ok "Remote 'origin' configured"
    fi

    $ok && return 0 || return 1
}

gh-check-divergent() {
    local dir="${1:-.}"
    local ahead behind
    git -C "$dir" fetch origin 2>/dev/null || true
    ahead=$(git -C "$dir" rev-list --count origin/main..HEAD 2>/dev/null || echo 0)
    behind=$(git -C "$dir" rev-list --count HEAD..origin/main 2>/dev/null || echo 0)
    if [[ "$ahead" -gt 0 && "$behind" -gt 0 ]]; then
        _gh_warn "Divergent branches: $ahead ahead, $behind behind origin/main"
        _gh_action "divergent"
    elif [[ "$ahead" -gt 0 ]]; then
        _gh_warn "$ahead commit(s) ahead of origin/main (need push)"
        _gh_action "ahead"
    elif [[ "$behind" -gt 0 ]]; then
        _gh_warn "$behind commit(s) behind origin/main (need pull)"
        _gh_action "behind"
    else
        _gh_ok "Up to date with origin/main"
    fi
    return 0
}

gh-check-all() {
    local dir="${1:-.}"
    local skip_dirty="${2:-false}"
    local skip_divergent="${3:-false}"

    echo ""
    echo "  ┌─ 🩺  Git Health Check ───────────────────────────"
    echo "  │  Repo: $dir"
    echo "  └──────────────────────────────────────────────────"
    echo ""

    gh-check-repo "$dir" || return 1
    gh-check-stale-merge "$dir"
    gh-check-lock "$dir"
    if [[ "$skip_dirty" != "true" ]]; then
        gh-check-dirty "$dir"
    fi
    gh-check-bogus-filenames "$dir"
    gh-check-crlf "$dir"
    if [[ "$skip_divergent" != "true" ]]; then
        gh-check-divergent "$dir"
    fi

    echo ""
    if [[ ${#_GIT_HEALTH_ACTIONS[@]} -eq 0 ]]; then
        _gh_ok "All checks passed — no issues found"
    else
        _gh_fix "Actions taken: ${_GIT_HEALTH_ACTIONS[*]}"
    fi
    echo ""
}

gh-report() {
    local dir="${1:-.}"
    echo ""
    echo "  ┌─ 🩺  Git Health Report ───────────────────────────"
    echo "  │  Repo: $dir"
    echo "  │  Branch: $(git -C "$dir" branch --show-current 2>/dev/null || echo 'unknown')"
    echo "  │  Last commit: $(git -C "$dir" log --oneline -1 2>/dev/null || echo 'none')"
    echo "  │  Modified: $(git -C "$dir" diff --stat 2>/dev/null | tail -1 || echo 'none')"
    echo "  │  Staged: $(git -C "$dir" diff --cached --stat 2>/dev/null | tail -1 || echo 'none')"
    echo "  │  Untracked: $(git -C "$dir" ls-files --others --exclude-standard 2>/dev/null | wc -l) file(s)"
    echo "  └──────────────────────────────────────────────────"
    echo ""
}
