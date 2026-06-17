#!/usr/bin/env bash

choose_partitions() {
    lsblk -p -o NAME,SIZE,FSTYPE,LABEL,PARTLABEL,PARTTYPENAME,TYPE,MOUNTPOINTS "$DISK"

    read -rp "Type the EFI System Partition: " EFI_PART
    read -rp "Type the ROOT partition: " ROOT_PART
}

check_esp() {
    local efi_fstype confirm

    efi_fstype="$(blkid -s TYPE -o value "$EFI_PART" 2>/dev/null || true)"
    [[ "$efi_fstype" == "vfat" ]] && return 0

    warn "$EFI_PART is not vfat/FAT32"
    read -rp "Format it as FAT32? Type 'YES' to continue: " confirm
    [[ "$confirm" == "YES" ]] || die "EFI partition is not vfat/FAT32: $EFI_PART"

    FORMAT_ESP="yes"
}

validate_partitions() {
    local parent
    local root_fstype
    local root_parttype

    [[ -b "$EFI_PART" ]] || die "EFI partition is not a block device: $EFI_PART"
    [[ -b "$ROOT_PART" ]] || die "Root partition is not a block device: $ROOT_PART"
    [[ "$EFI_PART" != "$ROOT_PART" ]] || die "EFI and ROOT partitions must be different."

    parent="$(lsblk -pno PKNAME "$EFI_PART" 2>/dev/null)"
    [[ "$parent" == "$DISK" ]] || die "EFI partition does not belong to selected disk: $EFI_PART"
    parent="$(lsblk -pno PKNAME "$ROOT_PART" 2>/dev/null)"
    [[ "$parent" == "$DISK" ]] || die "ROOT partition does not belong to selected disk: $ROOT_PART"

    root_fstype="$(blkid -s TYPE -o value "$ROOT_PART" 2>/dev/null || true)"
    root_parttype="$(lsblk -nrpo PARTTYPENAME "$ROOT_PART" 2>/dev/null || true)"
    [[ "$root_fstype" != "vfat" ]] || die "ROOT partition must not be the EFI partition: $ROOT_PART"
    [[ "$root_fstype" != "ntfs" ]] || die "ROOT partition must not be a Windows NTFS partition: $ROOT_PART"
    [[ "$root_parttype" != *"Windows recovery"* ]] ||
        die "ROOT partition must not be a Windows recovery partition: $ROOT_PART"
}

choose_partitions
validate_partitions
check_esp

save_state_var EFI_PART "$EFI_PART"
save_state_var ROOT_PART "$ROOT_PART"
