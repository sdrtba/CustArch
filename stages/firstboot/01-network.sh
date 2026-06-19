#!/usr/bin/env bash

network_is_ready() {
    ping -c 1 -W 3 aur.archlinux.org >/dev/null 2>&1
}

if network_is_ready; then
    log "Network is ready."
else
    warn "Network is not ready."

    if command -v nmtui-connect >/dev/null 2>&1 && [[ -r /dev/tty ]]; then
        log "Opening NetworkManager connection UI..."
        tui nmtui-connect || true
    fi

    network_is_ready || die "Network is not ready."
fi
