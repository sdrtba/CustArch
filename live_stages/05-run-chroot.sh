#!/usr/bin/env bash
set -euo pipefail
source "$LIB_DIR/common.sh"
load_config

TARGET_REPO="/mnt/root/CustArch"

rm -rf "$TARGET_REPO"
mkdir -p "$TARGET_REPO"
cp -a "$SCRIPT_DIR"/. "$TARGET_REPO"/

arch-chroot /mnt /bin/bash -lc 'cd /root/CustArch && ./chroot_stages/00-entry.sh'
