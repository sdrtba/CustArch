#!/usr/bin/env bash

run_live() {
    local type parent
    local root_fstype root_parttype efi_fstype

    [[ -b "$DISK" ]] || die "Disk does not exist: $DISK"
    type="$(lsblk -dn -o TYPE "$DISK" 2>/dev/null)"
    [[ "$type" == "disk" ]] || die "Chosen device is not a disk: $DISK"

    [[ -b "$EFI_PART" ]] || die "EFI partition does not exist: $EFI_PART"
    [[ -b "$ROOT_PART" ]] || die "Root partition does not exist: $ROOT_PART"

    parent="$(lsblk -pno PKNAME "$EFI_PART" 2>/dev/null)"
    [[ "$parent" == "$DISK" ]] || die "EFI partition does not belong to selected disk: $EFI_PART"
    parent="$(lsblk -pno PKNAME "$ROOT_PART" 2>/dev/null)"
    [[ "$parent" == "$DISK" ]] || die "ROOT partition does not belong to selected disk: $ROOT_PART"

    root_fstype="$(blkid -s TYPE -o value "$ROOT_PART" 2>/dev/null || true)"
    root_parttype="$(lsblk -nrpo PARTTYPENAME "$ROOT_PART" 2>/dev/null || true)"
    [[ "$root_fstype" != "vfat" ]] ||
        die "ROOT partition must not be the EFI partition: $ROOT_PART"
    [[ "$root_fstype" != "ntfs" ]] ||
        die "ROOT partition must not be a Windows NTFS partition: $ROOT_PART"
    [[ "$root_parttype" != *"Windows recovery"* ]] ||
        die "ROOT partition must not be a Windows recovery partition: $ROOT_PART"

    efi_fstype="$(blkid -s TYPE -o value "$EFI_PART" 2>/dev/null || true)"
    [[ "$efi_fstype" == "vfat" ]] ||
        die "EFI partition must be FAT32/vfat: $EFI_PART"

    findmnt /mnt >/dev/null 2>&1 && die "/mnt is already mounted."
}
