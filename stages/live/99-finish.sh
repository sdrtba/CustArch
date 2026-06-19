#!/usr/bin/env bash

log "$PHASE phase has finished."

if mountpoint -q /mnt; then
    umount -R /mnt || die "Failed to unmount /mnt"
else
    warn "/mnt is not mounted, skipping unmount."
fi

read -rp "Reboot now? [y/N]: " REBOOT_CONFIRM
if [[ "$REBOOT_CONFIRM" =~ ^[Yy]$ ]]; then
    reboot
fi
