#!/usr/bin/env bash
set -euo pipefail

echo "[*] Available disks:"
lsblk -d -o NAME,SIZE,MODEL,TYPE

echo
read -rp "Target disk: " DISK

[ -b "$DISK" ] || { echo "Disk not found: $DISK"; exit 1; }

read -rp "This will erase data on $DISK. Type YES to continue: " CONFIRM
[ "$CONFIRM" = "YES" ] || exit 1

cfdisk "$DISK"

echo
echo "[*] Resulting partition table:"
lsblk "$DISK"

read -rp "EFI partition: " EFI_PART
read -rp "ROOT partition: " ROOT_PART
read -rp "Filesystem for root [ext4]: " FS_TYPE

FS_TYPE="${FS_TYPE:-ext4}"
TIMEZONE="${TIMEZONE:-Europe/Amsterdam}"

save_config_var DISK "$DISK"
save_config_var EFI_PART "$EFI_PART"
save_config_var ROOT_PART "$ROOT_PART"
save_config_var FS_TYPE "$FS_TYPE"
