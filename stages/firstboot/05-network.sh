#!/usr/bin/env bash

network_is_ready() {
    ping -c 1 -W 3 aur.archlinux.org >/dev/null 2>&1
}

if ((${#AUR_PACKAGES[@]} == 0)); then
    log "No AUR packages configured; skipping network check."
elif network_is_ready; then
    log "Network is ready."
else
    warn "Network is required for AUR packages."

    if command -v nmtui-connect >/dev/null 2>&1 && [[ -r /dev/tty ]]; then
        warn "Opening NetworkManager connection UI..."
        tui nmtui-connect || true
    fi

    network_is_ready || die "Network is not ready. Connect to the network and reboot to retry firstboot."
fi
