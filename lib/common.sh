#!/usr/bin/env bash
set -euo pipefail

save_config_var() {
    local key="$1"
    local value="$2"
    echo "${key}=\"${value}\"" >> "$CONFIG_FILE"
}
