#!/usr/bin/env python3
"""
KDL Configuration Editor — Zellij config.kdl & theme .kdl parser/writer.

Commands:
  --get <filepath>                 List all active top-level settings with metadata
  --set <filepath> key=value       Update a single setting's value in-place
  --get-theme-colors <file>        List all color properties in a theme .kdl file
  --set-theme-color <file> k=v     Update a single color in a theme .kdl file in-place
  --list-themes <themesdir>        List available theme names from themes directory
"""
import argparse
import os
import re
import sys
from pathlib import Path


KNOWN_SETTINGS = [
    {
        "key": "simplified_ui",
        "type": "bool",
        "default": "false",
        "description": "Use simplified UI without special fonts (arrow glyphs)",
        "hint": "Enable if your terminal lacks Nerd Font support for arrow glyphs",
    },
    {
        "key": "osc8_hyperlinks",
        "type": "bool",
        "default": "true",
        "description": "Enable OSC 8 hyperlink output in terminal",
        "hint": "Makes clickable hyperlinks appear in supported terminals",
    },
    {
        "key": "theme",
        "type": "choice",
        "default": "default",
        "description": "Color theme for Zellij UI",
        "hint": "Restart Zellij to apply theme changes. 'default' uses Zellij's built-in theme.",
    },
    {
        "key": "theme_dark",
        "type": "choice",
        "default": "default",
        "description": "Theme override when terminal reports dark color scheme",
        "hint": "Only applied when theme_light is also set. Restart required.",
    },
    {
        "key": "theme_light",
        "type": "choice",
        "default": "default",
        "description": "Theme override when terminal reports light color scheme",
        "hint": "Only applied when theme_dark is also set. Restart required.",
    },
    {
        "key": "default_mode",
        "type": "choice",
        "choices": ["locked", "normal"],
        "default": "normal",
        "description": "Default input mode when starting a new Zellij session",
        "hint": "'locked': prevents accidental keypresses (vim-like). 'normal': direct input mode.",
    },
    {
        "key": "default_shell",
        "type": "string",
        "default": "",
        "description": "Shell binary path for new panes",
        "hint": "Absolute path to shell (e.g., /bin/zsh, /bin/bash). Empty = use $SHELL.",
    },
    {
        "key": "default_layout",
        "type": "string",
        "default": "default",
        "description": "Default layout loaded on session start",
        "hint": "Name of a layout file in the layout directory (without .kdl extension).",
    },
    {
        "key": "theme_dir",
        "type": "string",
        "default": "",
        "description": "Directory path for custom theme files",
        "hint": "Absolute path to a folder containing .kdl theme files. Restart required.",
    },
    {
        "key": "mouse_mode",
        "type": "bool",
        "default": "true",
        "description": "Enable mouse click and drag support",
        "hint": "Disable if mouse interactions interfere with text selection or copy/paste.",
    },
    {
        "key": "pane_frames",
        "type": "bool",
        "default": "true",
        "description": "Show visual frames and borders around panes",
        "hint": "Disable for a cleaner, borderless look.",
    },
    {
        "key": "copy_command",
        "type": "string",
        "default": "",
        "description": "External command for clipboard copy (piped stdin)",
        "hint": "Examples: 'xclip -sel clip' (X11), 'wl-copy' (Wayland), 'pbcopy' (macOS).",
    },
    {
        "key": "copy_clipboard",
        "type": "choice",
        "choices": ["system", "primary"],
        "default": "system",
        "description": "Clipboard destination for copied text",
        "hint": "'system': system clipboard. 'primary': X11 primary selection (middle-click).",
    },
    {
        "key": "copy_on_select",
        "type": "bool",
        "default": "true",
        "description": "Automatically copy text on mouse selection release",
        "hint": "Disable if you don't want automatic clipboard writes when selecting text.",
    },
    {
        "key": "show_startup_tips",
        "type": "bool",
        "default": "true",
        "description": "Show helpful tips when starting a new Zellij session",
        "hint": "Disable for a quieter startup experience.",
    },
]

SETTINGS_MAP = {s["key"]: s for s in KNOWN_SETTINGS}


def parse_kdl(filepath):
    """Parse a KDL config file and return active (non-commented) top-level settings.

    Returns list of dicts: {key, value, raw_type, type, line_index}
    Only includes entries at brace-depth 0 that are not commented out.
    """
    settings = []
    brace_depth = 0
    in_multiline_comment = False

    with open(filepath, "r") as f:
        lines = f.readlines()

    for i, raw_line in enumerate(lines):
        line = raw_line.strip()

        if not line:
            continue

        if line.startswith("/*"):
            in_multiline_comment = True
            continue
        if in_multiline_comment:
            if "*/" in line:
                in_multiline_comment = False
            continue

        if line.startswith("//") or line.startswith("#"):
            continue

        if "{" in line:
            brace_depth += 1
            if brace_depth == 1:
                continue

        if "}" in line:
            brace_depth -= 1
            if brace_depth == 0:
                continue
            continue

        if brace_depth > 0:
            continue

        match = re.match(r'^(\w[\w.-]*)\s+(.+?)\s*(?://.*)?$', line)
        if not match:
            continue

        key = match.group(1)
        raw_value = match.group(2).strip().rstrip(";")

        # Strip trailing inline comment
        raw_value = re.sub(r'\s*//.*$', '', raw_value).strip()
        raw_value = re.sub(r'\s*#.*$', '', raw_value).strip()

        # Determine raw type
        if raw_value in ("true", "false"):
            raw_type = "bool"
        elif raw_value.startswith('"') and raw_value.endswith('"'):
            raw_type = "string"
            raw_value = raw_value[1:-1]
        elif raw_value.isdigit():
            raw_type = "integer"
        else:
            raw_type = "string"

        settings.append({
            "key": key,
            "value": raw_value,
            "raw_type": raw_type,
            "type": raw_type,
            "line_index": i,
        })

    return settings


def enrich_settings(settings, themes_dir=None):
    """Merge known metadata into parsed settings list."""
    themes = list_themes(themes_dir) if themes_dir else None

    for s in settings:
        meta = SETTINGS_MAP.get(s["key"])
        if meta:
            s["type"] = meta["type"]
            s["description"] = meta["description"]
            s["hint"] = meta["hint"]
            s["default"] = meta["default"]

            if meta["type"] == "choice":
                if s["key"].startswith("theme") and themes:
                    s["choices"] = themes + ["default"]
                else:
                    s["choices"] = meta.get("choices", [])
            elif meta["type"] == "bool":
                s["choices"] = ["true", "false"]
        else:
            s["description"] = f"Unknown setting '{s['key']}'"
            s["hint"] = f"Generic value of type '{s['raw_type']}'. Edit with care."
            s["default"] = s["value"]

            if s["raw_type"] == "bool":
                s["type"] = "bool"
                s["choices"] = ["true", "false"]
            else:
                s["type"] = "string"
                s["choices"] = []

    return settings


def parse_theme_colors(filepath):
    """Parse a Zellij theme .kdl file and return color key|value pairs.

    Format: themes { <name> { color_key "hex_value" ... } }
    Returns list of {key, value, line_index} for color properties at depth 2.
    """
    colors = []
    brace_depth = 0
    in_multiline_comment = False

    with open(filepath, "r") as f:
        lines = f.readlines()

    for i, raw_line in enumerate(lines):
        line = raw_line.strip()

        if not line:
            continue

        if line.startswith("/*"):
            in_multiline_comment = True
            continue
        if in_multiline_comment:
            if "*/" in line:
                in_multiline_comment = False
            continue

        if line.startswith("//") or line.startswith("#"):
            continue

        if "{" in line:
            brace_depth += 1
            continue

        if "}" in line:
            brace_depth -= 1
            continue

        if brace_depth < 2:
            continue

        match = re.match(r'^(\w[\w.-]*)\s+(.+?)\s*(?://.*)?$', line)
        if not match:
            continue

        key = match.group(1)
        raw_value = match.group(2).strip().rstrip(";")
        raw_value = re.sub(r'\s*//.*$', '', raw_value).strip()
        raw_value = re.sub(r'\s*#.*$', '', raw_value).strip()

        if raw_value.startswith('"') and raw_value.endswith('"'):
            raw_value = raw_value[1:-1]

        colors.append({
            "key": key,
            "value": raw_value,
            "line_index": i,
        })

    return colors


def update_theme_color(filepath, key, new_value):
    """Update a color property in a Zellij theme .kdl file in-place.

    Handles nested brace depth (themes { name { ... } }).
    Preserves formatting and comments.
    Returns (success: bool, message: str)
    """
    if not os.path.isfile(filepath):
        return False, f"File not found: {filepath}"

    with open(filepath, "r") as f:
        lines = f.readlines()

    key_lower = key.lower()
    found = False
    brace_depth = 0
    in_multiline_comment = False

    for i, raw_line in enumerate(lines):
        line = raw_line.strip()

        if not line:
            continue

        if line.startswith("/*"):
            in_multiline_comment = True
            continue
        if in_multiline_comment:
            if "*/" in line:
                in_multiline_comment = False
            continue

        if line.startswith("//") or line.startswith("#"):
            continue

        if "{" in line:
            brace_depth += 1
            continue

        if "}" in line:
            brace_depth -= 1
            continue

        if brace_depth < 2:
            continue

        match = re.match(r'^(\w[\w.-]*)\s+(.+?)\s*(?://.*)?$', line)
        if not match:
            continue

        candidate_key = match.group(1)
        if candidate_key.lower() != key_lower:
            continue

        raw_value = match.group(2).strip().rstrip(";")
        raw_value = re.sub(r'\s*//.*$', '', raw_value).strip()

        if raw_value.startswith('"') and raw_value.endswith('"'):
            new_line = re.sub(
                r'^(\s*\w[\w.-]*\s+)"[^"]*"(\s*.*)$',
                r'\1"' + new_value + r'"\2',
                raw_line,
            )
        else:
            new_line = re.sub(
                r'^(\s*\w[\w.-]*\s+)' + re.escape(raw_value) + r'(\s*.*)$',
                r'\1' + new_value + r'\2',
                raw_line,
            )

        lines[i] = new_line
        found = True
        break

    if not found:
        return False, f"Color '{key}' not found in theme file"

    with open(filepath, "w") as f:
        f.writelines(lines)

    return True, f"Color '{key}' updated to '{new_value}'"


def list_themes(themes_dir):
    """Return list of theme names (stem of .kdl files in themes_dir)."""
    if not themes_dir or not os.path.isdir(themes_dir):
        return []
    themes = []
    for f in sorted(os.listdir(themes_dir)):
        if f.endswith(".kdl"):
            themes.append(Path(f).stem)
    return themes


def format_for_display(settings):
    """Format settings as pipe-delimited lines for fzf consumption.

    Columns: key | value | type | description | hint | choices
    """
    lines = []
    for s in settings:
        key = s["key"]
        value = s["value"]
        stype = s["type"]
        desc = s.get("description", "")
        hint = s.get("hint", "")
        choices = ",".join(s.get("choices", []))
        lines.append(f"{key}|{value}|{stype}|{desc}|{hint}|{choices}")
    return "\n".join(lines)


def update_setting(filepath, key, new_value):
    """Update a setting in the KDL file in-place, preserving formatting and comments.

    Returns (success: bool, message: str)
    """
    if not os.path.isfile(filepath):
        return False, f"File not found: {filepath}"

    with open(filepath, "r") as f:
        lines = f.readlines()

    key_lower = key.lower()
    found = False
    brace_depth = 0
    in_multiline_comment = False

    for i, raw_line in enumerate(lines):
        line = raw_line.strip()

        if not line:
            continue

        if line.startswith("/*"):
            in_multiline_comment = True
            continue
        if in_multiline_comment:
            if "*/" in line:
                in_multiline_comment = False
            continue

        if line.startswith("//") or line.startswith("#"):
            continue

        if "{" in line:
            brace_depth += 1
            if brace_depth == 1:
                continue

        if "}" in line:
            brace_depth -= 1
            if brace_depth == 0:
                continue
            continue

        if brace_depth > 0:
            continue

        match = re.match(r'^(\w[\w.-]*)\s+(.+?)\s*(?://.*)?$', line)
        if not match:
            continue

        candidate_key = match.group(1)
        if candidate_key.lower() != key_lower:
            continue

        raw_value = match.group(2).strip().rstrip(";")
        raw_value = re.sub(r'\s*//.*$', '', raw_value).strip()

        # Determine the format of the original value
        if raw_value in ("true", "false"):
            new_line = re.sub(
                r'^(\s*\w[\w.-]*\s+)' + re.escape(raw_value) + r'(\s*.*)$',
                r'\1' + new_value + r'\2',
                raw_line,
            )
        elif raw_value.startswith('"') and raw_value.endswith('"'):
            new_line = re.sub(
                r'^(\s*\w[\w.-]*\s+)"[^"]*"(\s*.*)$',
                r'\1"' + new_value + r'"\2',
                raw_line,
            )
        else:
            new_line = re.sub(
                r'^(\s*\w[\w.-]*\s+)' + re.escape(raw_value) + r'(\s*.*)$',
                r'\1' + new_value + r'\2',
                raw_line,
            )

        lines[i] = new_line
        found = True
        break

    if not found:
        return False, f"Setting '{key}' not found in config file"

    with open(filepath, "w") as f:
        f.writelines(lines)

    return True, f"Setting '{key}' updated to '{new_value}'"


def main():
    parser = argparse.ArgumentParser(description="KDL Configuration Editor")
    parser.add_argument("--get", metavar="FILE", help="List all active settings")
    parser.add_argument("--set", nargs=2, metavar=("FILE", "KEY=VAL"),
                        help="Update a setting: <file> <key=value>")
    parser.add_argument("--get-theme-colors", metavar="FILE",
                        help="List all color properties in a theme .kdl file")
    parser.add_argument("--set-theme-color", nargs=2, metavar=("FILE", "KEY=VAL"),
                        help="Update a theme color: <file> <key=value>")
    parser.add_argument("--list-themes", metavar="DIR", help="List themes in directory")
    parser.add_argument("--get-themes-dir", action="store_true",
                        help="Print the expected themes directory path")

    args = parser.parse_args()

    if args.get:
        filepath = args.get
        if not os.path.isfile(filepath):
            print(f"Error: file not found: {filepath}", file=sys.stderr)
            sys.exit(1)

        # Script is at common/palette/kdl_config.py, repo root is 3 levels up
        repo_root = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
        themes_dir = os.path.join(repo_root, "common", "config", "zellij", "themes")

        settings = parse_kdl(filepath)
        settings = enrich_settings(settings, themes_dir)
        print(format_for_display(settings))

    elif args.set:
        filepath, kv = args.set
        if "=" not in kv:
            print("Error: argument must be in key=value format", file=sys.stderr)
            sys.exit(1)
        key, value = kv.split("=", 1)
        success, message = update_setting(filepath, key, value)
        if success:
            print(message)
        else:
            print(f"Error: {message}", file=sys.stderr)
            sys.exit(1)

    elif args.get_theme_colors:
        filepath = args.get_theme_colors
        if not os.path.isfile(filepath):
            print(f"Error: file not found: {filepath}", file=sys.stderr)
            sys.exit(1)
        colors = parse_theme_colors(filepath)
        for c in colors:
            print(f"{c['key']}|{c['value']}")

    elif args.set_theme_color:
        filepath, kv = args.set_theme_color
        if "=" not in kv:
            print("Error: argument must be in key=value format", file=sys.stderr)
            sys.exit(1)
        key, value = kv.split("=", 1)
        success, message = update_theme_color(filepath, key, value)
        if success:
            print(message)
        else:
            print(f"Error: {message}", file=sys.stderr)
            sys.exit(1)

    elif args.list_themes:
        themes = list_themes(args.list_themes)
        for t in themes:
            print(t)

    elif args.get_themes_dir:
        repo_root = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
        themes_dir = os.path.join(repo_root, "common", "config", "zellij", "themes")
        print(themes_dir)

    else:
        parser.print_help()


if __name__ == "__main__":
    main()
