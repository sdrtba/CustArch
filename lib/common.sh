#!/usr/bin/env bash

set -euo pipefail

WORKDIR="/tmp/custarch"
CONFIG_FILE="$WORKDIR/install.conf"

require_root() {
    if [ "$(id -u)" -ne 0 ]; then
        echo "[!] Run as root"
        exit 1
    fi
}

require_uefi() {
    if [ ! -d /sys/firmware/efi/efivars ]; then
        echo "[!] UEFI mode not detected"
        exit 1
    fi
}

load_config() {
    if [ ! -f "$CONFIG_FILE" ]; then
        echo "[!] Config file not found: $CONFIG_FILE"
        exit 1
    fi
    # shellcheck disable=SC1090
    source "$CONFIG_FILE"
}

save_config_var() {
    local key="$1"
    local value="$2"
    echo "${key}=\"${value}\"" >> "$CONFIG_FILE"
}
