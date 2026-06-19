#!/usr/bin/env bash

log "Enabling system services..."
systemctl enable NetworkManager.service
systemctl enable bluetooth.service
systemctl enable power-profiles-daemon.service
systemctl enable ufw.service
systemctl enable systemd-timesyncd.service

log "Configuring firewall defaults..."
ufw default deny incoming
ufw default allow outgoing

if [[ -f /etc/ufw/ufw.conf ]]; then
    sed -i 's/^ENABLED=.*/ENABLED=yes/' /etc/ufw/ufw.conf
fi
