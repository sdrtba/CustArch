#!/usr/bin/env bash
set -euo pipefail

COMMON_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
: "${SCRIPT_DIR:=$(cd -- "$COMMON_DIR/.." && pwd)}"
: "${LIB_DIR:=$SCRIPT_DIR/lib}"
: "${STAGES_DIR:=$SCRIPT_DIR/stages}"
: "${CONFIG_FILE:=$SCRIPT_DIR/install.conf}"

load_config() {
    [ -f "$CONFIG_FILE" ] || { echo "Missing $CONFIG_FILE"; exit 1; }
    source "$CONFIG_FILE"
}

save_config_var() {
    local key="$1"
    local value="$2"
    local escaped_value
    escaped_value="${value//\\/\\\\}"
    escaped_value="${escaped_value//\"/\\\"}"

    if grep -q "^${key}=" "$CONFIG_FILE"; then
        sed -i "s|^${key}=.*|${key}=\"${escaped_value}\"|" "$CONFIG_FILE"
    else
        echo "${key}=\"${escaped_value}\"" >> "$CONFIG_FILE"
    fi
}
