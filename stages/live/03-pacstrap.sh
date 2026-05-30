#!/usr/bin/env bash
set -Eeuo pipefail
source "$LIB_DIR/common.sh"
load_config
require_root

source "$LIB_DIR/packages.sh"

main() {
    reflector -c Russia -a 12 --latest 10 --protocol https --sort rate --save /etc/pacman.d/mirrorlist

    pacstrap -K /mnt \
        "${PACSTRAP_PACKAGES[@]}"

    genfstab -U /mnt > /mnt/etc/fstab
}

main "$@"
