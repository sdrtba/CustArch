#!/usr/bin/env bash
set -Eeuo pipefail
source "$LIB_DIR/common.sh"
load_config
require_root

choose_fs() {
  local fs
  choose_from_list "Choose root filesystem" fs \
      "ext4" \
      "btrfs"
  FS_TYPE="$fs"
  log "Selected filesystem: $FS_TYPE"
}

mount_partitions() {
  mkdir -p /mnt
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
}

main() {
  [[ -b "$EFI_PART" ]] || die "EFI_PART is not a block device: ${EFI_PART:-empty}"
  [[ -b "$ROOT_PART" ]] || die "ROOT_PART is not a block device: ${ROOT_PART:-empty}"
  [[ "$EFI_PART" != "$ROOT_PART" ]] || die "EFI_PART and ROOT_PART must be different."
  mountpoint -q /mnt && die "/mnt is already mounted. Unmount it before running this stage."

  choose_fs
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

  case "$FS_TYPE" in
    ext4)
      mkfs.ext4 -F "$ROOT_PART"
      ;;
    btrfs)
      mkfs.btrfs -f "$ROOT_PART"
      ;;
    *)
      die "Unsupported filesystem: $FS_TYPE"
      ;;
  esac

  mount_partitions
}

main "$@"
