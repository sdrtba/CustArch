#!/usr/bin/env bash
set -euo pipefail
source "$LIB_DIR/common.sh"
load_config

umount -R /mnt

read -rp "Reboot now? [y/N]: " REBOOT_CONFIRM
if [[ "$REBOOT_CONFIRM" =~ ^[Yy]$ ]]; then
    reboot
fi
