# Security Scanning & Vulnerability Management

> [!WARNING]
> Registered: 2026-06-21-02-25-00
> Status: Active

## Policy Overview
Every environment update (pull) and workspace commit (sync) runs a mandatory security audit scanner to prevent credential exposure or syntax vulnerabilities.

## Audit Functions (`dot-scan`)
1. **Static Analysis**: Shellcheck scans scripts to ensure clean syntax and catch logic traps.
2. **Secret Scans**: Heuristic searches check for credentials (excluding typical system variables).
3. **Outdated Checks**: Audit Homebrew packages for security updates.
4. **System Audits**: Lynis performs system hardening audits.
