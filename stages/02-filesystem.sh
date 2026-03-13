#!/usr/bin/env bash
set -euo pipefail
source "$LIB_DIR/common.sh"
load_config

echo "$EFI_PART"

# CHANGE THIS IN DUAL BOOT SCENARIO
mkfs.fat -F32 "$EFI_PART"

case "$FS_TYPE" in
  ext4)
    mkfs.ext4 "$ROOT_PART"
    ;;
  btrfs)
    mkfs.btrfs "$ROOT_PART"
    ;;
  *)
    echo "Unsupported filesystem: $FS_TYPE"
    exit 1
    ;;
esac
