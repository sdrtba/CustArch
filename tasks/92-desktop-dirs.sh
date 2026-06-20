#!/usr/bin/env bash

run_post() {
    if [[ "$INSTALL_HYPRLAND" == "yes" ]]; then
        runuser -u "$USERNAME" -- xdg-user-dirs-update || true
    fi
}
