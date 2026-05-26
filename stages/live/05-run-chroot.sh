#!/usr/bin/env bash
set -Eeuo pipefail
source "$LIB_DIR/common.sh"
load_config
require_root

main() {
  TARGET_DIR="/mnt/root/CustArch"

  mountpoint -q /mnt || die "/mnt is not mounted. Run 02-filesystem.sh first."

  rm -rf "$TARGET_DIR"
  mkdir -p "$TARGET_DIR"
  cp -a "$ROOT_DIR"/. "$TARGET_DIR"/

  arch-chroot /mnt /bin/bash -lc 'cd /root/CustArch && ./stages/chroot/00-entry.sh'
}

main "$@"
