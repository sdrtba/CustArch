#!/usr/bin/env bash

choose_disk() {
    local -a disks

    mapfile -t disks < <(lsblk -dpno NAME,TYPE | awk '$2 == "disk" { print $1 }')
    ((${#disks[@]} > 0)) || die "No disks found."

    log "Available disks:"
    lsblk -dp -o NAME,SIZE,MODEL,SERIAL,TRAN,TYPE

    choose_from_list "Choose target disk:" DISK "${disks[@]}"
    save_state_var DISK "$DISK"
    log "Selected disk: $DISK"
}

run_cfdisk() {
    command -v cfdisk >/dev/null 2>&1 || die "cfdisk is not available."

    log "Opening cfdisk for $DISK..."
    tui cfdisk "$DISK"

    if command -v partprobe >/dev/null 2>&1; then
        partprobe "$DISK" || true
    else
        blockdev --rereadpt "$DISK" || true
    fi

    udevadm settle
}

choose_partitions() {
    local -a partitions
    local selected

    mapfile -t partitions < <(lsblk -nrpo NAME,TYPE "$DISK" | awk '$2 == "part" { print $1 }')

    lsblk -p -o NAME,SIZE,FSTYPE,LABEL,PARTLABEL,PARTTYPENAME,TYPE,MOUNTPOINTS "$DISK"

    choose_from_list "Choose shared Windows + Arch EFI System Partition" selected "${partitions[@]}"
    save_state_var EFI_PART "$selected"
    log "Selected EFI partition: $selected"

    choose_from_list "Choose Arch ROOT partition to format" selected "${partitions[@]}"
    save_state_var ROOT_PART "$selected"
    log "Selected ROOT partition: $selected"
}

validate_partitions() {
    local efi_fstype
    local root_fstype
    local root_parttype

    [[ -b "$EFI_PART" ]] || die "EFI partition is not a block device: $EFI_PART"
    [[ -b "$ROOT_PART" ]] || die "Root partition is not a block device: $ROOT_PART"
    [[ "$EFI_PART" != "$ROOT_PART" ]] || die "EFI and ROOT partitions must be different."

    efi_fstype="$(blkid -s TYPE -o value "$EFI_PART")"
    if [[ "$efi_fstype" != "vfat" ]]; then
        warn "Looks like $EFI_PART not is vfat/FAT32"
        confirm_dialog "Would you want to format $EFI_PART?" "YES"
        mkfs.vfat "$EFI_PART"
    fi

    root_fstype="$(blkid -s TYPE -o value "$ROOT_PART" 2>/dev/null || true)"
    root_parttype="$(lsblk -nrpo PARTTYPENAME "$ROOT_PART" 2>/dev/null || true)"

    [[ "$root_fstype" != "vfat" ]] || die "ROOT partition must not be the EFI partition: $ROOT_PART"
    [[ "$root_fstype" != "ntfs" ]] || die "ROOT partition must not be a Windows NTFS partition: $ROOT_PART"
    [[ "$root_parttype" != *"Windows recovery"* ]] ||
        die "ROOT partition must not be a Windows recovery partition: $ROOT_PART"
}

choose_disk
run_cfdisk
choose_partitions
validate_partitions

confirm_dialog "Selected ROOT partition will be formatted" "YES"
