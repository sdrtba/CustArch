#!/usr/bin/env bash
set -Eeuo pipefail
source "$ROOT_DIR/lib/paths.sh"
source "$LIB_DIR/common.sh"
load_config
require_root

choose_wifi() {
    local -a networks menu
    local line ssid security signal selected

    nmcli device wifi rescan >/dev/null 2>&1 || true
    mapfile -t networks < <(nmcli -t --escape yes -f SSID,SECURITY,SIGNAL device wifi list | awk -F: '$1 != ""')
    ((${#networks[@]} > 0)) || {
        log "No Wi-Fi networks found, skipping Wi-Fi setup."
        return 1
    }

    for line in "${networks[@]}"; do
        IFS=: read -r ssid security signal <<< "$line"
        menu+=("$ssid  ${security:-open}  ${signal:-0}%")
    done

    choose_from_list "Choose Wi-Fi network" selected "${menu[@]}"
    WIFI_SSID="${selected%%  *}"
    log "Selected Wi-Fi network: $WIFI_SSID"
}

connect_wifi() {
    local wifi_password

    read -rsp "Wi-Fi password (leave empty for open network): " wifi_password
    echo

    if [[ -n "$wifi_password" ]]; then
        nmcli device wifi connect "$WIFI_SSID" password "$wifi_password"
    else
        nmcli device wifi connect "$WIFI_SSID"
    fi
}

main() {
    if ! command -v nmcli >/dev/null 2>&1; then
        warn "nmcli not found, skipping Wi-Fi setup."
        return 0
    fi

    if ! nmcli -t -f DEVICE,TYPE device status | grep -q ':wifi$'; then
        log "No Wi-Fi adapter found, skipping Wi-Fi setup."
        return 0
    fi

    nmcli radio wifi on >/dev/null 2>&1 || true
    choose_wifi || return 0
    connect_wifi
}

main "$@"
