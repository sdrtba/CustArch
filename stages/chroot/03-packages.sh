#!/usr/bin/env bash

log "Installing common packages..."
pacman_install "${PACMAN_COMMON_PACKAGES[@]}"

log "Enabling system services..."
enable_service bluetooth.service
enable_service power-profiles-daemon.service
enable_service ufw.service
enable_service NetworkManager.service
enable_service systemd-timesyncd.service

log "Configuring firewall defaults..."
ufw default deny incoming
ufw default allow outgoing

if [[ -f /etc/ufw/ufw.conf ]]; then
    sed -i 's/^ENABLED=.*/ENABLED=yes/' /etc/ufw/ufw.conf
fi
