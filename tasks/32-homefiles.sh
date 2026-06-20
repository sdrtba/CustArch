#!/usr/bin/env bash

run_chroot() {
    local source_dir="$TARGET_DIR/home"
    local destination_dir="/home/$USERNAME"

    [[ -d "$source_dir" ]] || return 0

    id "$USERNAME" >/dev/null 2>&1 || die "User does not exist: $USERNAME"
    mkdir -p "$destination_dir"

    rsync -a \
        --chown="$USERNAME:$USERNAME" \
        --exclude '.gitkeep' \
        --exclude '.cache/' \
        --exclude '.local/state/' \
        --exclude '.ssh/' \
        --exclude '.gnupg/' \
        "$source_dir"/ "$destination_dir"/
}
