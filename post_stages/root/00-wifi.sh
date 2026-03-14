#!/usr/bin/env bash
set -euo pipefail
source "$LIB_DIR/common.sh"
load_config

if ! command -v nmcli >/dev/null 2>&1; then
    echo "[!] nmcli not found, skipping Wi-Fi setup."
    exit 0
fi

if ! nmcli -t -f DEVICE,TYPE device status | grep -q ':wifi$'; then
    echo "[*] No Wi-Fi adapter found, skipping Wi-Fi setup."
    exit 0
fi

nmcli radio wifi on >/dev/null 2>&1 || true

echo "[*] Available Wi-Fi networks:"
nmcli --colors no --fields IN-USE,SSID,SECURITY,SIGNAL device wifi list || true
echo
read -rp "Wi-Fi SSID (leave empty to skip): " WIFI_SSID

if [[ -z "$WIFI_SSID" ]]; then
    echo "[*] Wi-Fi setup skipped."
    exit 0
fi

read -rsp "Wi-Fi password (leave empty for open network): " WIFI_PASSWORD
echo

if [[ -n "$WIFI_PASSWORD" ]]; then
    nmcli device wifi connect "$WIFI_SSID" password "$WIFI_PASSWORD"
else
    nmcli device wifi connect "$WIFI_SSID"
fi
