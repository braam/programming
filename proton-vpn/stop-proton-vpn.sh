#!/bin/bash

# Check if the script is run as root
if [ "$EUID" -ne 0 ]; then
    echo "[-] This script must be run as root."
    echo "Usage: doas ./stop-proton-vpn.sh"
    exit 1
fi

CONFIG_NAME="proton-vpn"

echo "[-] Stopping ProtonVPN ($CONFIG_NAME)..."
wg-quick down "$CONFIG_NAME"

if [ $? -eq 0 ]; then
    echo "[+] VPN successfully stopped and network settings restored."
else
    echo "[-] Error stopping the VPN (it might already be stopped)."
    exit 1
fi
