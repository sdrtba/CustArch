#!/usr/bin/env bash
set -euo pipefail
source "$LIB_DIR/common.sh"
load_config

echo "$EFI_PART"

# mkfs.fat -F32 "$EFI_PART"

# case "$FS_TYPE" in
#   ext4)
#     mkfs.ext4 -F "$ROOT_PART"
#     ;;
#   btrfs)
#     mkfs.btrfs -f "$ROOT_PART"
#     ;;
#   *)
#     echo "Unsupported filesystem: $FS_TYPE"
#     exit 1
#     ;;
# esac

# if [ -n "${SWAP_PART:-}" ]; then
#     mkswap "$SWAP_PART"
# fi
