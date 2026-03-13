#!/usr/bin/env bash
set -euo pipefail

load_config() {
    [ -f "$CONFIG_FILE" ] || { echo "Missing $CONFIG_FILE"; exit 1; }
    # shellcheck disable=SC1090
    source "$CONFIG_FILE"
}

save_config_var() {
    local key="$1"
    local value="$2"
    echo "${key}=\"${value}\"" >> "$CONFIG_FILE"
}
