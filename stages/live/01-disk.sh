#!/usr/bin/env bash

choose_disk() {
    local type

    log "Available disks:"
    lsblk -dp -o NAME,SIZE,MODEL,SERIAL,TRAN,TYPE

    read -rp "Type the target disk: " DISK

    type="$(lsblk -dn -o TYPE "$DISK" 2>/dev/null)"
    [[ "$type" == "disk" ]] || die "Chosen device is not a disk: $DISK"

    log "Selected disk: $DISK"
}

run_cfdisk() {
    log "Opening cfdisk for $DISK..."
    tui cfdisk "$DISK"

    log "Reloading partition table..."

    partprobe "$DISK" 2>/dev/null || blockdev --rereadpt "$DISK" 2>/dev/null || true

    udevadm settle 2>/dev/null || true
}

choose_disk
run_cfdisk

save_state_var DISK "$DISK"
