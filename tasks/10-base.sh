#!/usr/bin/env bash

run_live() {
    mapfile -t packages < <(target_packages | sort -u)
    pacstrap -K /mnt "${packages[@]}"
    genfstab -U /mnt > /mnt/etc/fstab

    mkdir -p "/mnt$TARGET_DIR"
    rsync -a --delete \
        --exclude '.git' \
        --exclude 'var' \
        "$SCRIPT_DIR/" "/mnt$TARGET_DIR"

    if [[ -n "${LOG_FILE:-}" && -f "$LOG_FILE" ]]; then
        mkdir -p /mnt/var/log/custarch
        install -m 0644 "$LOG_FILE" "/mnt/var/log/custarch/$(basename "$LOG_FILE")"
    fi

    arch-chroot /mnt "$TARGET_DIR/install.sh" --chroot
}
