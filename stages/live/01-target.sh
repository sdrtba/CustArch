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

reread_partition_table() {
    if command -v partprobe >/dev/null 2>&1; then
        partprobe "$DISK" || true
    else
        blockdev --rereadpt "$DISK" || true
    fi

    udevadm settle
}

run_cfdisk() {
    command -v cfdisk >/dev/null 2>&1 || die "cfdisk is not available."

    confirm_dialog "Manual partitioning can destroy data on $DISK." "PARTITION"

    log "Opening cfdisk for $DISK..."
    tui cfdisk "$DISK"

    reread_partition_table
}

ask_for_cfdisk() {
    read -r -p "Open cfdisk before choosing partitions? [yN]: " check
    if [[ "$check" =~ ^[Yy](es)?$ ]]; then
        run_cfdisk
    fi
}

choose_partitions() {
    local -a partitions
    local selected

    mapfile -t partitions < <(lsblk -nrpo NAME,TYPE "$DISK" | awk '$2 == "part" { print $1 }')
    ((${#partitions[@]} >= 2)) ||
        die "At least two partitions are required on $DISK: EFI and ROOT."

    choose_from_list "Choose EFI System Partition" selected "${partitions[@]}"
    save_state_var EFI_PART "$selected"
    log "Selected EFI partition: $selected"

    choose_from_list "Choose ROOT partition" selected "${partitions[@]}"
    save_state_var ROOT_PART "$selected"
    log "Selected ROOT partition: $selected"
}

ask_for_efi_format() {
    read -r -p "Format EFI System Partition? [yN]: " check
    case "${check,,}" in
        y|yes)
            save_state_var FORMAT_ESP "yes"
            ;;
        *)
            save_state_var FORMAT_ESP "no"
            ;;
    esac
}

print_install_plan() {
    cat <<EOF

Install plan
------------
Target disk:       $DISK
EFI partition:     $EFI_PART
Root partition:    $ROOT_PART
Format ESP:        $FORMAT_ESP
EOF
}

choose_disk
ask_for_cfdisk
choose_partitions
ask_for_efi_format

[[ -b "$EFI_PART" ]] || die "EFI partition is not a block device: $EFI_PART"
[[ -b "$ROOT_PART" ]] || die "Root partition is not a block device: $ROOT_PART"
[[ "$EFI_PART" != "$ROOT_PART" ]] || die "EFI and ROOT partitions must be different."

if [[ "$FORMAT_ESP" == "no" ]]; then
    [[ "$(blkid -s TYPE -o value "$EFI_PART")" == "vfat" ]] ||
        die "Existing EFI partition must use FAT32: $EFI_PART"
fi

print_install_plan

confirm_dialog "The root partition(s) will be formatted." "FORMAT"
