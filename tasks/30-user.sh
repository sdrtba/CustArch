#!/usr/bin/env bash

run_chroot() {
    log "Set password for root"
    passwd

    if ! id "$USERNAME" >/dev/null 2>&1; then
        useradd -m -G wheel -s /bin/bash "$USERNAME"
    fi

    sed -i 's/^# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' /etc/sudoers

    log "Set password for $USERNAME"
    passwd "$USERNAME"
}
