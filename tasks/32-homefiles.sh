#!/usr/bin/env bash

run_chroot() {
    # shellcheck disable=SC2153
    local source_dir="$TARGET_DIR/home"
    local target_dir="/home/$USERNAME"

    [[ "$INSTALL_HOMEFILES" == "yes" ]] || return 0
    [[ -d "$source_dir" ]] || return 0

    id "$USERNAME" >/dev/null 2>&1 || die "User does not exist: $USERNAME"
    mkdir -p "$target_dir"

    rsync -a \
        --chown="$USERNAME:$USERNAME" \
        --exclude '.gitkeep' \
        --exclude '.cache/' \
        --exclude '.local/state/' \
        --exclude '.ssh/' \
        --exclude '.gnupg/' \
        "$source_dir"/ "$target_dir"/
}
