#!/bin/bash

# Check if the script is run as root
if [ "$EUID" -ne 0 ]; then
    echo "[-] This script must be run as root."
    echo "Usage: doas ./start-proton-vpn.sh"
    exit 1
fi

# Find any .conf file in the current directory
CONF_FILE=$(ls *.conf 2>/dev/null | head -n 1)

if [ -z "$CONF_FILE" ]; then
    echo "[-] Error: No .conf file found in this directory!"
    exit 1
fi

echo "[+] Found configuration file: $CONF_FILE"

# 1. Remove any existing 'DNS = ...' line to prevent resolvconf conflicts
if grep -q "^DNS[[:space:]]*=" "$CONF_FILE"; then
    echo "[+] Removing existing 'DNS =' line from configuration..."
    sed -i '/^DNS[[:space:]]*=/d' "$CONF_FILE"
fi

# Required rules for Tailscale and Manual DNS
LINE1="# Keep Tailscale accessible in combo with proton vpn"
LINE2="PostUp = ip route add 100.64.0.0/10 dev tailscale0 2>/dev/null || true"
LINE3="PostDown = ip route del 100.64.0.0/10 dev tailscale0 2>/dev/null || true"
LINE4="# 2. Manual DNS settings (bypass resolvconf error)"
LINE5="PostUp = echo 'nameserver 10.2.0.1' >> /etc/resolv.conf"
LINE6="PostDown = sed -i '/nameserver 10.2.0.1/d' /etc/resolv.conf"

# Check and append missing rules under [Interface] if not already present
if ! grep -q "ip route add 100.64.0.0/10" "$CONF_FILE"; then
    echo "[+] Required PostUp/PostDown rules missing. Adding them to [Interface]..."
    
    awk -v l1="$LINE1" -v l2="$LINE2" -v l3="$LINE3" -v l4="$LINE4" -v l5="$LINE5" -v l6="$LINE6" '
    /^\[Interface\]/ {
        print
        print l1
        print l2
        print l3
        print l4
        print l5
        print l6
        next
    }
    { print }
    ' "$CONF_FILE" > "${CONF_FILE}.tmp" && mv "${CONF_FILE}.tmp" "$CONF_FILE"
else
    echo "[+] Required PostUp/PostDown rules are already present in the configuration file."
fi

# Copy the file to the target location
TARGET_PATH="/etc/wireguard/proton-vpn.conf"
echo "[+] Copying to $TARGET_PATH..."
cp "$CONF_FILE" "$TARGET_PATH"
chmod 600 "$TARGET_PATH"

# Start the VPN
echo "[+] Starting ProtonVPN via WireGuard (proton-vpn)..."
wg-quick up proton-vpn

if [ $? -eq 0 ]; then
    echo "[+] Connection successfully established!"
    wg show proton-vpn
else
    echo "[-] An error occurred while starting the VPN."
    exit 1
fi
