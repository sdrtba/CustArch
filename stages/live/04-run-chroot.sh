#!/usr/bin/env bash
set -Eeuo pipefail
source "$LIB_DIR/common.sh"
load_config
require_root

main() {
    local target_dir="/mnt/root/$PROJECT_NAME"

    mountpoint -q /mnt || die "/mnt is not mounted. Run 02-filesystem.sh first."

    rm -rf "$target_dir"
    mkdir -p "$target_dir"
    cp -a "$ROOT_DIR"/. "$target_dir"/

    arch-chroot /mnt /bin/bash -lc "cd /root/$PROJECT_NAME && ./stages/chroot/00-entry.sh"
}

main "$@"
