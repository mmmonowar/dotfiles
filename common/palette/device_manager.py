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


def load_devices(yaml_path):
    devices = {}
    if not os.path.exists(yaml_path):
        return devices
    current_device = None
    with open(yaml_path) as f:
        for line in f:
            stripped = line.strip()
            if not stripped or stripped.startswith('#'):
                continue
            if line.startswith('  - id:'):
                current_device = stripped.split(':', 1)[1].strip()
                devices[current_device] = {}
            elif current_device and ':' in stripped:
                parts = stripped.split(':', 1)
                k = parts[0].strip()
                v = parts[1].strip()
                devices[current_device][k] = v
    return devices


def save_devices(yaml_path, devices):
    with open(yaml_path, 'w') as f:
        f.write("devices:\n")
        for dev_id in sorted(devices.keys()):
            dev = devices[dev_id]
            f.write(f"  - id: {dev_id}\n")
            for key in ['username', 'device-name', 'device-model',
                        'operating-system', 'operating-system-version',
                        'ip-address', 'last-sync']:
                f.write(f"    {key}: {dev.get(key, '')}\n")


def cmd_list(data_path):
    yaml_path = os.path.join(data_path, 'device-list.yml')
    devices = load_devices(yaml_path)
    for dev_id in sorted(devices.keys()):
        dev = devices[dev_id]
        print(f"{dev_id} | {dev.get('device-name', '')} | "
              f"{dev.get('ip-address', '')} | {dev.get('username', '')} | "
              f"{dev.get('operating-system', '')}")


def cmd_detect():
    hostname = run_cmd("hostname") or "unknown-device"
    device_id = "".join([c.lower() for c in hostname if c.isalnum() or c in "-_"])
    username = run_cmd("whoami") or "unknown"

    uname_s = run_cmd("uname -s").lower()
    if "darwin" in uname_s:
        os_name = "mac"
        os_version = run_cmd("sw_vers -productVersion")
        device_model = run_cmd("sysctl -n hw.model")
    else:
        uname_a = run_cmd("uname -a").lower()
        if "microsoft" in uname_a or "wsl" in uname_a:
            os_name = "wsl"
        else:
            os_name = "linux"
        os_version = run_cmd("lsb_release -sr")
        if not os_version:
            os_version = run_cmd(
                "grep VERSION_ID /etc/os-release | cut -d= -f2"
            ).replace('"', '').strip()
        device_model = run_cmd("cat /sys/class/dmi/id/product_name")
        if not device_model:
            device_model = run_cmd(
                "cat /sys/devices/virtual/dmi/id/product_name"
            )
        if not device_model:
            device_model = "Generic Linux"

    ip_addr = get_ip()

    print(f"id={device_id}")
    print(f"username={username}")
    print(f"device-name={hostname}")
    print(f"device-model={device_model}")
    print(f"operating-system={os_name}")
    print(f"operating-system-version={os_version}")
    print(f"ip-address={ip_addr}")


def cmd_update(data_path, fields):
    yaml_path = os.path.join(data_path, 'device-list.yml')
    os.makedirs(data_path, exist_ok=True)

    devices = load_devices(yaml_path)

    dev_id = fields.get('id', '')
    if not dev_id:
        print("Error: id field is required")
        sys.exit(1)

    if dev_id not in devices:
        devices[dev_id] = {}

    for key, value in fields.items():
        if key != 'id':
            devices[dev_id][key] = value

    devices[dev_id]['last-sync'] = datetime.datetime.now().strftime(
        "%Y-%m-%d-%H-%M-%S"
    )

    save_devices(yaml_path, devices)
    print(f"Device '{dev_id}' saved.")


if __name__ == '__main__':
    if len(sys.argv) < 3:
        print("Usage:")
        print("  device_manager.py <data_path> --list")
        print("  device_manager.py <data_path> --detect")
        print("  device_manager.py <data_path> --update id=xxx [field=value ...]")
        sys.exit(1)

    data_path = sys.argv[1]
    command = sys.argv[2]

    if command == '--list':
        cmd_list(data_path)
    elif command == '--detect':
        cmd_detect()
    elif command == '--update':
        fields = {}
        for arg in sys.argv[3:]:
            if '=' in arg:
                k, v = arg.split('=', 1)
                fields[k] = v
        cmd_update(data_path, fields)
    else:
        print(f"Unknown command: {command}")
        sys.exit(1)
