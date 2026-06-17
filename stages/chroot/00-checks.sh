#!/usr/bin/env bash

is_chroot() {
    local current_root init_root

    current_root="$(stat -c '%d:%i' /)" || return 1
    init_root="$(stat -Lc '%d:%i' /proc/1/root/.)" || return 1

    [[ "$current_root" != "$init_root" ]]
}

log "Checking chroot environment..."

is_chroot || die "This phase must be run inside chroot."
mountpoint -q /boot || die "/boot is not mounted"
[[ -n "${ROOT_UUID:-}" ]] || die "ROOT_UUID is empty"

log "Chroot environment is ready."
