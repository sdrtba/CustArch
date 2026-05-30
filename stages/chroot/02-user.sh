#!/usr/bin/env bash
set -Eeuo pipefail
source "$LIB_DIR/common.sh"
load_config
require_root

main() {
    local target_repo

    echo "Set root password"
    passwd

    if id "$USERNAME" >/dev/null 2>&1; then
        warn "User $USERNAME already exists, skipping creation"
    else
        log "Create a new user"
        useradd -m -G wheel -s /bin/bash "$USERNAME"
        passwd "$USERNAME"
    fi

    echo "$USERNAME ALL=(ALL) ALL" > "/etc/sudoers.d/$USERNAME"
    chmod 0440 "/etc/sudoers.d/$USERNAME"

    target_repo="/home/$USERNAME/$PROJECT_NAME"

    rm -rf "$target_repo"
    mkdir -p "$target_repo"
    cp -a "$ROOT_DIR"/. "$target_repo"/
    chown -R "$USERNAME":"$USERNAME" "$target_repo"
}

main "$@"
