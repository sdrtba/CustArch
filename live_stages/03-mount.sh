#!/usr/bin/env bash
set -euo pipefail
source "$LIB_DIR/common.sh"
load_config

mount "$ROOT_PART" /mnt

if [ "$FS_TYPE" = "btrfs" ]; then
    btrfs subvolume create /mnt/@
    btrfs subvolume create /mnt/@home
    umount /mnt

    mount -o noatime,compress=zstd,subvol=@ "$ROOT_PART" /mnt
    mkdir -p /mnt/{home,efi}
    mount -o noatime,compress=zstd,subvol=@home "$ROOT_PART" /mnt/home
fi

mkdir -p /mnt/efi
mount "$EFI_PART" /mnt/efi
