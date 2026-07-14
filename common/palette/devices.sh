#!/bin/bash

# ==========================================
# 󰖟  DEVICE MANAGER
# ==========================================

function devices_menu() {
    local dim="\033[2m"
    local reset="\033[0m"

    local list_items=""
    list_items+="1 | 󰖟  Scan Current Device | ${dim}Auto-detect and update device info${reset} | ACTION | scan_device
"
    list_items+="2 | 󰒔  SSH into Device | ${dim}Connect to a registered device${reset} | ACTION | ssh_device
"
    list_items+="3 | 󰌋  Manual Device Entry | ${dim}Add or update device data via prompts${reset} | ACTION | manual_device
"
    list_items+="4 | 󰅙  Back | ${dim}Return to main menu${reset} | ACTION | main_menu"

    local selection=$(echo -e "$list_items" | fzf \
        --ansi \
        --height 100% \
        --reverse \
        --border rounded \
        --prompt "󰖟  " \
        --header "Device Manager" \
        --delimiter ' \| ')

    if [[ -z "$selection" ]]; then main_menu; return; fi

    local type arg
    type=$(echo "$selection" | cut -d '|' -f 4 | xargs)
    arg=$(echo "$selection" | cut -d '|' -f 5 | xargs)

    case "$type" in
        ACTION)
            case "$arg" in
                scan_device) scan_current_device ;;
                ssh_device) ssh_into_device ;;
                manual_device) manual_device_entry ;;
                main_menu) main_menu ;;
            esac
            ;;
    esac
}

function scan_current_device() {
    clear
    echo "󰖟  Scanning current device..."
    echo "----------------------------------------"
    python3 "$PALETTE_LIB/update_device.py" "$DOTFILES_DATA"
    local exit_code=$?
    echo ""
    if [[ $exit_code -eq 0 ]]; then
        echo "󰄬  Scan complete."
    else
        echo "󰅙  Scan failed (exit code $exit_code)."
    fi
    printf "\nPress Enter to return..."
    read -r
    devices_menu
}

function ssh_into_device() {
    local dim="\033[2m"
    local reset="\033[0m"

    local device_data=$(python3 "$PALETTE_LIB/device_manager.py" "$DOTFILES_DATA" --list)

    if [[ -z "$device_data" ]]; then
        clear
        echo "󰅙  No devices found in device-list.yml"
        sleep 2
        devices_menu
        return
    fi

    local selection=$(echo -e "$device_data" | fzf \
        --ansi \
        --height 100% \
        --reverse \
        --border rounded \
        --prompt "󰒔  " \
        --header "Select a device to SSH into" \
        --delimiter ' \| ' \
        --preview "
            echo 'Device: {2}'
            echo '  ID:  {1}'
            echo '  User: {4}'
            echo '  IP:   {3}'
            echo '  OS:   {5}'
        ")

    if [[ -z "$selection" ]]; then
        devices_menu
        return
    fi

    local device_id=$(echo "$selection" | cut -d '|' -f 1 | xargs)
    local device_name=$(echo "$selection" | cut -d '|' -f 2 | xargs)
    local ip_addr=$(echo "$selection" | cut -d '|' -f 3 | xargs)
    local username=$(echo "$selection" | cut -d '|' -f 4 | xargs)

    if [[ -z "$ip_addr" || "$ip_addr" == "127.0.0.1" || "$ip_addr" == "0.0.0.0" ]]; then
        clear
        echo "󰅙  No valid IP address for $device_name"
        sleep 2
        devices_menu
        return
    fi

    clear
    echo "󰒔  SSH Connection"
    echo "------------------------"
    echo " Device: $device_name ($device_id)"
    echo " User:   $username"
    echo " IP:     $ip_addr"
    echo ""

    if confirm_action "Connect to $username@$ip_addr?"; then
        trigger_zsh_func "ssh $username@$ip_addr"
    else
        devices_menu
    fi
}

function manual_device_entry() {
    clear
    echo "󰌋  Manual Device Entry"
    echo "------------------------"
    echo "Press Enter to accept the default value shown in brackets."
    echo ""

    local detected_info=$(python3 "$PALETTE_LIB/device_manager.py" "$DOTFILES_DATA" --detect)
    local detected_id=$(echo "$detected_info" | grep "^id=" | head -1 | cut -d= -f2-)
    local detected_user=$(echo "$detected_info" | grep "^username=" | head -1 | cut -d= -f2-)
    local detected_hostname=$(echo "$detected_info" | grep "^device-name=" | head -1 | cut -d= -f2-)
    local detected_model=$(echo "$detected_info" | grep "^device-model=" | head -1 | cut -d= -f2-)
    local detected_os=$(echo "$detected_info" | grep "^operating-system=" | head -1 | cut -d= -f2-)
    local detected_osver=$(echo "$detected_info" | grep "^operating-system-version=" | head -1 | cut -d= -f2-)
    local detected_ip=$(echo "$detected_info" | grep "^ip-address=" | head -1 | cut -d= -f2-)

    printf "Device ID [%s]: " "$detected_id"
    read -r device_id
    device_id="${device_id:-$detected_id}"

    printf "Username [%s]: " "$detected_user"
    read -r username
    username="${username:-$detected_user}"

    printf "Device Name [%s]: " "$detected_hostname"
    read -r device_name
    device_name="${device_name:-$detected_hostname}"

    printf "Device Model [%s]: " "$detected_model"
    read -r device_model
    device_model="${device_model:-$detected_model}"

    printf "Operating System [%s]: " "$detected_os"
    read -r operating_system
    operating_system="${operating_system:-$detected_os}"

    printf "OS Version [%s]: " "$detected_osver"
    read -r os_version
    os_version="${os_version:-$detected_osver}"

    printf "IP Address [%s]: " "$detected_ip"
    read -r ip_address
    ip_address="${ip_address:-$detected_ip}"

    clear
    echo "󰌋  Device Summary"
    echo "------------------------"
    echo " ID:              $device_id"
    echo " Username:        $username"
    echo " Device Name:     $device_name"
    echo " Device Model:    $device_model"
    echo " Operating System: $operating_system"
    echo " OS Version:      $os_version"
    echo " IP Address:      $ip_address"
    echo ""

    if confirm_action "Save this device?"; then
        python3 "$PALETTE_LIB/device_manager.py" "$DOTFILES_DATA" --update \
            id="$device_id" \
            username="$username" \
            device-name="$device_name" \
            device-model="$device_model" \
            operating-system="$operating_system" \
            operating-system-version="$os_version" \
            ip-address="$ip_address"
        echo ""
        printf "Press Enter to return..."
        read -r
    fi
    devices_menu
}
