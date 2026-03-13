#!/usr/bin/env bash

set -euo pipefail

WORKDIR="/tmp/custarch"
CONFIG_FILE="$WORKDIR/install.conf"

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
