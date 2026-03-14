#!/usr/bin/env bash
set -euo pipefail
source "$LIB_DIR/common.sh"
load_config

echo "[*] Available disks:"
lsblk -d -o NAME,SIZE,MODEL,TYPE

echo
read -rp "Target disk: " DISK

[ -b "$DISK" ] || { echo "Disk not found: $DISK"; exit 1; }

read -rp "This will erase data on $DISK. Type 'y' to continue: " CONFIRM
[ "$CONFIRM" = "y" ] || exit 1

cfdisk "$DISK"

echo
echo "[*] Resulting partition table:"
lsblk "$DISK"

read -rp "EFI partition: " EFI_PART
read -rp "ROOT partition: " ROOT_PART
read -rp "Filesystem for root [ext4]: " FS_TYPE

FS_TYPE="${FS_TYPE:-ext4}"

save_config_var DISK "$DISK"
save_config_var EFI_PART "$EFI_PART"
save_config_var ROOT_PART "$ROOT_PART"
save_config_var FS_TYPE "$FS_TYPE"
