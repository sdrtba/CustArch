#!/usr/bin/env bash
set -Eeuo pipefail
source "$LIB_DIR/common.sh"
load_config
require_root

make_partitions() {
  if [[ "$FS_TYPE" = "ext4" ]]; then
    mkfs.ext4 -F "$ROOT_PART"
    mkdir -p /mnt
    mount "$ROOT_PART" /mnt
  elif [[ "$FS_TYPE" = "btrfs" ]]; then
    mkfs.btrfs -f "$ROOT_PART"
    mkdir -p /mnt
    mount "$ROOT_PART" /mnt

    btrfs subvolume create /mnt/@
    btrfs subvolume create /mnt/@home
    umount /mnt

    mount -o noatime,compress=zstd,subvol=@ "$ROOT_PART" /mnt
    mkdir -p /mnt/{home,efi}
    mount -o noatime,compress=zstd,subvol=@home "$ROOT_PART" /mnt/home
  else
    die "Unsupported filesystem: $FS_TYPE"
  fi

  mkdir -p /mnt/efi
  mount "$EFI_PART" /mnt/efi
}

main() {
  choose_from_list "Choose root filesystem" FS_TYPE \
      "ext4" \
      "btrfs"
  log "Selected filesystem: $FS_TYPE"
  save_config_var FS_TYPE "$FS_TYPE"

  log "EFI partition: $EFI_PART"
  read -rp "Format EFI partition? Use yes only for fresh ESP, no for dual-boot. [y/N]: " CONFIRM
  if [[ "$CONFIRM" =~ ^[Yy]$ ]]; then
    mkfs.fat -F32 "$EFI_PART"
    save_config_var DUAL_BOOT "NO"
  else
    log "Skipping EFI partition format."
    save_config_var DUAL_BOOT "YES"
  fi

  make_partitions
}

main "$@"
