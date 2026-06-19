#!/usr/bin/env bash

run_live() {
    mapfile -t packages < <(target_packages | sort -u)
    pacstrap -K /mnt "${packages[@]}"
    genfstab -U /mnt >> /mnt/etc/fstab

    copy_self_to_target "/mnt$TARGET_DIR"

    arch-chroot /mnt "$TARGET_DIR/install.sh" --chroot
}
