#!/usr/bin/env bash
set -Eeuo pipefail
source "$LIB_DIR/common.sh"
load_config
require_root

main() {
  if mountpoint -q /mnt; then
    umount -R /mnt
  else
    warn "/mnt is not mounted, skipping unmount."
  fi

  read -rp "Reboot now? [y/N]: " REBOOT_CONFIRM
  if [[ "$REBOOT_CONFIRM" =~ ^[Yy]$ ]]; then
    reboot
  fi
}

main "$@"
