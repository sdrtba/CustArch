#!/usr/bin/env bash

log "Set root password:"
passwd

if ! id "$USERNAME" >/dev/null 2>&1; then
    useradd -m -G wheel -s /bin/bash "$USERNAME"
fi

log "Set password for $USERNAME:"
passwd "$USERNAME"

printf '%%wheel ALL=(ALL:ALL) ALL\n' > /etc/sudoers.d/wheel
chmod 0440 /etc/sudoers.d/wheel
