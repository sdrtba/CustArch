#!/usr/bin/env bash
set -Eeuo pipefail
source "$ROOT_DIR/lib/paths.sh"
source "$LIB_DIR/common.sh"
load_config
require_root
source "$LIB_DIR/packages.sh"

main() {
    pacman_install "${PACMAN_PACKAGES[@]}"
}

main "$@"
