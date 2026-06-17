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

choose_partitions() {
    local -a partitions
    local selected

    mapfile -t partitions < <(lsblk -nrpo NAME,TYPE "$DISK" | awk '$2 == "part" { print $1 }')
    ((${#partitions[@]} > 0)) || die "No partitions found on $DISK."

    echo
    lsblk -o NAME,SIZE,FSTYPE,LABEL,PARTLABEL,TYPE,MOUNTPOINTS "$DISK"

    choose_from_list "Choose existing EFI System Partition" selected "${partitions[@]}"
    save_state_var EFI_PART "$selected"
    log "Selected partition: $selected"

    choose_from_list "Choose ROOT partition to format" selected "${partitions[@]}"
    save_state_var ROOT_PART "$selected"
    log "Selected partition: $selected"
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
choose_partitions
choose_from_list "Format EFI System Partition:" FORMAT_ESP no yes
save_state_var FORMAT_ESP "$FORMAT_ESP"

[[ -b "$EFI_PART" ]] || die "EFI partition is not a block device: $EFI_PART"
[[ -b "$ROOT_PART" ]] || die "Root partition is not a block device: $ROOT_PART"
[[ "$EFI_PART" != "$ROOT_PART" ]] || die "EFI and ROOT partitions must be different."

if [[ "$FORMAT_ESP" == "no" ]]; then
    [[ "$(blkid -s TYPE -o value "$EFI_PART")" == "vfat" ]] ||
        die "Existing EFI partition must use FAT32: $EFI_PART"
fi

print_install_plan

message="The root partition will be formatted."
if [[ "$FORMAT_ESP" == "yes" ]]; then
    message="The root and EFI partitions will be formatted."
fi

confirm_dialog "$message" "FORMAT"
