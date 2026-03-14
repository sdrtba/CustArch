#!/usr/bin/env bash
set -euo pipefail
source "$LIB_DIR/common.sh"
load_config

echo "EFI partition: $EFI_PART"
read -rp "Format EFI partition? Use 'YES' for fresh ESP, skip for dual-boot: " FORMAT_EFI_CONFIRM
if [[ "$FORMAT_EFI_CONFIRM" = "YES" ]]; then
    mkfs.fat -F32 "$EFI_PART"
fi

case "$FS_TYPE" in
  ext4)
    mkfs.ext4 -F "$ROOT_PART"
    ;;
  btrfs)
    mkfs.btrfs -f "$ROOT_PART"
    ;;
  *)
    echo "Unsupported filesystem: $FS_TYPE"
    exit 1
    ;;
esac
