#!/usr/bin/env python3
import sys
import os
import subprocess
import socket
import datetime

def run_cmd(cmd):
    try:
        return subprocess.check_output(cmd, shell=True, text=True, stderr=subprocess.DEVNULL).strip()
    except Exception:
        return ""

def get_ip():
    s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    try:
        s.connect(('1.1.1.1', 1))
        ip = s.getsockname()[0]
    except Exception:
        ip = "127.0.0.1"
    finally:
        s.close()
    return ip

def main():
    repo_root = sys.argv[1] if len(sys.argv) > 1 else os.getcwd()
    data_dir = os.path.join(repo_root, "data")
    os.makedirs(data_dir, exist_ok=True)
    yaml_path = os.path.join(data_dir, "device-list.yml")

    # Generate device identifier
    hostname = run_cmd("hostname")
    if not hostname:
        hostname = "unknown-device"
    device_id = "".join([c.lower() for c in hostname if c.isalnum() or c in "-_"])

    username = run_cmd("whoami")
    
    # OS Detection
    uname_s = run_cmd("uname -s").lower()
    if "darwin" in uname_s:
        os_name = "mac"
        os_version = run_cmd("sw_vers -productVersion")
        device_model = run_cmd("sysctl -n hw.model")
    else:
        # Check for WSL
        uname_a = run_cmd("uname -a").lower()
        if "microsoft" in uname_a or "wsl" in uname_a:
            os_name = "wsl"
        else:
            os_name = "linux"
        os_version = run_cmd("lsb_release -sr")
        if not os_version:
            # Fallback
            os_version = run_cmd("grep VERSION_ID /etc/os-release | cut -d= -f2").replace('"', '').strip()
        device_model = run_cmd("cat /sys/class/dmi/id/product_name")
        if not device_model:
            device_model = run_cmd("cat /sys/devices/virtual/dmi/id/product_name")
        if not device_model:
            device_model = "Generic Linux"

    ip_addr = get_ip()
    
    # Timestamp: YYYY-MM-DD-hh-mm-ss
    last_sync = datetime.datetime.now().strftime("%Y-%m-%d-%H-%M-%S")

    # Load existing devices
    devices = {}
    if os.path.exists(yaml_path):
        current_device = None
        with open(yaml_path, "r") as f:
            for line in f:
                line_strip = line.strip()
                if not line_strip or line_strip.startswith("#"):
                    continue
                if line.startswith("  - id:"):
                    current_device = line_strip.split(":", 1)[1].strip()
                    devices[current_device] = {}
                elif current_device and ":" in line_strip:
                    parts = line_strip.split(":", 1)
                    k = parts[0].strip()
                    v = parts[1].strip() if len(parts) > 1 else ""
                    devices[current_device][k] = v

    # Update or add current device
    devices[device_id] = {
        "username": username,
        "device-name": hostname,
        "device-model": device_model,
        "operating-system": os_name,
        "operating-system-version": os_version,
        "ip-address": ip_addr,
        "last-sync": last_sync
    }

    # Write back to YAML
    with open(yaml_path, "w") as f:
        f.write("devices:\n")
        # Sort to keep file diffs clean
        for dev_id in sorted(devices.keys()):
            dev = devices[dev_id]
            f.write(f"  - id: {dev_id}\n")
            f.write(f"    username: {dev.get('username', '')}\n")
            f.write(f"    device-name: {dev.get('device-name', '')}\n")
            f.write(f"    device-model: {dev.get('device-model', '')}\n")
            f.write(f"    operating-system: {dev.get('operating-system', '')}\n")
            f.write(f"    operating-system-version: {dev.get('operating-system-version', '')}\n")
            f.write(f"    ip-address: {dev.get('ip-address', '')}\n")
            f.write(f"    last-sync: {dev.get('last-sync', '')}\n")

    print(f"Updated {device_id} in {yaml_path}")

if __name__ == "__main__":
    main()
